# frozen_string_literal: true

require './lib/schema-viz/sources/structure-file/parser'
require './lib/schema-viz/utils/result'

module SchemaViz
  module Source
    module StructureFile
      Table = Struct.new(:schema, :table, :columns, :primary_key, :comment) do
        def copy(schema: nil, table: nil, columns: nil, primary_key: nil, comment: nil)
          Table.new(schema || self.schema, table || self.table, columns || self.columns, primary_key || self.primary_key, comment || self.comment)
        end

        def same?(other)
          schema == other.schema && table == other.table
        end
      end
      Column = Struct.new(:column, :type, :nullable, :default, :reference, :comment) do
        def copy(column: nil, type: nil, nullable: nil, default: nil, reference: nil, comment: nil)
          Column.new(column || self.column, type || self.type, nullable || self.nullable, default || self.default, reference || self.reference, comment || self.comment)
        end

        def same?(other)
          column == other.column
        end
      end
      Reference = Struct.new(:schema, :table, :column, :key_name)
      Structure = Struct.new(:tables) do
        def table(schema, table)
          tables.find { |t| t.schema == schema && t.table == table }
        end

        def column(schema, table, column)
          table(schema, table)&.columns&.find { |c| c.column == column }
        end

        def copy(tables: nil)
          Structure.new(tables || self.tables)
        end

        def add_table_r(table)
          if tables.find { |t| t.same?(table) }.nil?
            Result.of(copy(tables: tables + [table]))
          else
            Result.failure(TableAlreadyExists.from_table(table))
          end
        end

        def update_table_r(statement)
          raise TypeError, 'a block is expected' unless block_given?

          if tables.find { |table| table.same?(statement) }.nil?
            Result.failure(TableNotFound.from_statement(statement))
          else
            Result.seq(tables.map { |table| table.same?(statement) ? Result.expected!(yield(table)) : Result.of(table) })
                  .map { |new_tables| copy(tables: new_tables) }
          end
        end

        def update_column_r(statement)
          raise TypeError, 'a block is expected' unless block_given?

          update_table_r(statement) do |table|
            if table.columns.find { |column| column.same?(statement) }.nil?
              Result.failure(ColumnNotFound.from_statement(statement))
            else
              Result.seq(table.columns.map { |column| column.same?(statement) ? Result.expected!(yield(column)) : Result.of(column) })
                    .map { |new_columns| table.copy(columns: new_columns) }
            end
          end
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

        def parse_schema_file_r(path)
          @file_service.read_lines_r(path).flat_map do |lines|
            statements = build_statements(lines)
            statements.inject(Result.of(Structure.new([]))) do |structure_r, statement|
              structure_r.flat_and(Parser.parse_statement_r(statement)) { |structure, parsed_statement| evolve_r(structure, parsed_statement) }
            end
          end
        end

        def build_statements(lines)
          lines.reject { |line| line.empty? || line.start_with?('--') }
               .map { |line| "#{line}\n" }.join.split(";\n")
               .map { |statement| "#{statement.gsub(/\n/, ' ').gsub(/ +/, ' ').strip};" }
        end

        def evolve_r(structure, parsed_statement)
          case parsed_statement
          in Parser::Table => table
            columns = table.columns.map { |c| Column.new(c.column, c.type, c.nullable, c.default, nil, nil) }
            structure.add_table_r(Table.new(table.schema, table.table, columns, nil, nil))
          in Parser::TableComment => comment
            structure.update_table_r(comment) { |table| Result.of(table.copy(comment: comment.comment)) }
          in Parser::ColumnComment => comment
            structure.update_column_r(comment) { |column| Result.of(column.copy(comment: comment.comment)) }
          in Parser::PrimaryKey => pk
            structure.update_table_r(pk) { |table| Result.of(table.copy(primary_key: pk.columns)) }
          in Parser::ForeignKey => fk
            reference = Reference.new(fk.dest_schema, fk.dest_table, fk.dest_column, fk.name)
            structure.update_column_r(fk) { |column| Result.of(column.copy(reference: reference)) }
          in Parser::SetColumnDefault => default
            structure.update_column_r(default) { |column| Result.of(column.copy(default: default.value)) }
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
