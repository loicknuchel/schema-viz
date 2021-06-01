# frozen_string_literal: true

require './lib/schema-viz/sources/structure-file/parser'

module SchemaViz
  module Source
    module StructureFile
      Structure = Struct.new(:src, :tables) do
        def copy(tables: self.tables)
          Structure.new(src, tables)
        end

        def table(schema, table)
          tables.find { |t| t.schema == schema && t.table == table }
        end

        def column(schema, table, column)
          table(schema, table)&.columns&.find { |c| c.column == column }
        end

        def add_table(table)
          if tables.find { |t| t.same?(table) }.nil?
            Result.of(copy(tables: tables + [table]))
          else
            Result.failure(TableAlreadyExists.from_table(table))
          end
        end

        def update_table(statement)
          raise TypeError, 'a block is expected' unless block_given?

          if tables.find { |table| table.same?(statement) }.nil?
            Result.failure(TableNotFound.from_statement(statement))
          else
            Result.seq(tables.map { |table| table.same?(statement) ? Result.expected!(yield(table)) : Result.of(table) })
                  .map { |new_tables| copy(tables: new_tables) }
          end
        end

        def update_column(statement)
          raise TypeError, 'a block is expected' unless block_given?

          update_table(statement) do |table|
            if table.columns.find { |column| column.same?(statement) }.nil?
              Result.failure(ColumnNotFound.from_statement(statement))
            else
              Result.seq(table.columns.map { |column| column.same?(statement) ? Result.expected!(yield(column)) : Result.of(column) })
                    .map { |new_columns| table.copy(columns: new_columns) }
            end
          end
        end
      end
      Table = Struct.new(:src, :schema, :table, :columns, :primary_key, :uniques, :checks, :comment) do
        def copy(schema: self.schema, table: self.table, columns: self.columns, primary_key: self.primary_key, uniques: self.uniques, checks: self.checks, comment: self.comment)
          Table.new(src, schema, table, columns, primary_key, uniques, checks, comment)
        end

        def same?(other)
          schema == other.schema && table == other.table
        end
      end
      Column = Struct.new(:src, :column, :type, :nullable, :default, :reference, :comment) do
        def copy(column: self.column, type: self.type, nullable: self.nullable, default: self.default, reference: self.reference, comment: self.comment)
          Column.new(src, column, type, nullable, default, reference, comment)
        end

        def same?(other)
          column == other.column
        end
      end
      PrimaryKey = Struct.new(:src, :columns, :name)
      Unique = Struct.new(:src, :columns, :name)
      Check = Struct.new(:src, :predicate, :name)
      Reference = Struct.new(:src, :schema, :table, :column, :name)
      Statement = Struct.new(:file, :line, :lines) do
        def text
          lines.map(&:text).join(' ').gsub(/ +/, ' ').strip
        end
      end

      class TableAlreadyExists < StandardError
        def initialize(schema, table)
          super("Table #{schema}.#{table} already exists")
        end

        def self.from_table(table)
          self.new(table.schema, table.table)
        end
      end

      class TableNotFound < StandardError
        def initialize(schema, table, ctx = nil)
          super("Table #{schema}.#{table} not found#{ctx ? ", from #{ctx}" : ''}")
        end

        def self.from_statement(statement)
          self.new(statement.schema, statement.table, statement.to_s)
        end
      end

      class ColumnNotFound < StandardError
        def initialize(schema, table, name, ctx = nil)
          super("Column #{schema}.#{table}.#{name} not found#{ctx ? ", from #{ctx}" : ''}")
        end

        def self.from_statement(statement)
          self.new(statement.schema, statement.table, statement.name, statement.to_s)
        end
      end

      class Service

        def initialize(file_service)
          @file_service = file_service
        end

        def parse_schema_file(path)
          @file_service.read(path).map(&:lines).flat_map do |lines|
            statements = build_statements(lines)
            statements.inject(Result.of(Structure.new(path, []))) do |structure_r, statement|
              structure_r.flat_and(Parser.parse_statement(statement.text)) do |structure, parsed_statement|
                evolve(structure, statement, parsed_statement)
              end
            end
          end
        end

        def build_statements(lines)
          lines.reject { |line| line.text.empty? || line.text.start_with?('--') }
               .chunk_while { |before, _after| !before.text.end_with?(';') }
               .map { |statement_lines| Statement.new(statement_lines.first.file, statement_lines.first.line, statement_lines) }
        end

        def evolve(structure, statement, parsed_statement)
          case parsed_statement
          in Parser::Table => table
            columns = table.columns.map do |c|
              line = statement.lines.find { |line| line.text.strip.start_with?(c.column) }
              Column.new(line, c.column, c.type, c.nullable, c.default, Option.empty, Option.empty)
            end
            structure.add_table(Table.new(statement, table.schema, table.table, columns, Option.empty, [], [], Option.empty))
          in Parser::TableComment => comment
            structure.update_table(comment) { |table| Result.of(table.copy(comment: Option.of(comment.comment))) }
          in Parser::ColumnComment => comment
            structure.update_column(comment) { |column| Result.of(column.copy(comment: Option.of(comment.comment))) }
          in Parser::PrimaryKey => pk
            primary_key = PrimaryKey.new(statement, pk.columns, pk.name)
            structure.update_table(pk) { |table| Result.of(table.copy(primary_key: Option.of(primary_key))) }
          in Parser::ForeignKey => fk
            reference = Reference.new(statement, fk.dest_schema, fk.dest_table, fk.dest_column, fk.name)
            structure.update_column(fk) { |column| Result.of(column.copy(reference: Option.of(reference))) }
          in Parser::UniqueConstraint => unique
            constraint = Unique.new(statement, unique.columns, unique.name)
            structure.update_table(unique) { |table| Result.of(table.copy(uniques: table.uniques + [constraint])) }
          in Parser::CheckConstraint => check
            constraint = Check.new(statement, check.predicate, check.name)
            structure.update_table(check) { |table| Result.of(table.copy(checks: table.checks + [constraint])) }
          in Parser::SetColumnDefault => default
            structure.update_column(default) { |column| Result.of(column.copy(default: default.value)) }
          in Parser::SetColumnStatistics
            Result.of(structure) # do nothing
          in ->(v) do
            v.instance_of?(String) && [
              'CREATE TYPE',
              'CREATE FUNCTION',
              'CREATE VIEW',
              'CREATE OR REPLACE VIEW',
              'CREATE MATERIALIZED VIEW',
              'COMMENT ON VIEW',
              'CREATE INDEX',
              'CREATE UNIQUE INDEX',
              'COMMENT ON INDEX',
              'CREATE EXTENSION',
              'COMMENT ON EXTENSION',
              'CREATE TEXT SEARCH CONFIGURATION',
              'ALTER TEXT SEARCH CONFIGURATION',
              'CREATE SCHEMA',
              'CREATE SEQUENCE',
              'ALTER SEQUENCE',
              'SET',
              'SELECT',
              'INSERT INTO',
              'END'
            ].any? { |start| v.start_with?(start) }
          end # ignored statements
            Result.of(structure)
          else
            Result.failure(StandardError.new("statement not handled: #{parsed_statement.inspect}"))
          end
        end
      end
    end
  end
end
