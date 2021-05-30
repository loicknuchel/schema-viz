# frozen_string_literal: true

require './lib/schema-viz/utils/result'

module SchemaViz
  module Parser
    # parse a PostgreSQL file
    module Postgresql
      Table = Struct.new(:schema, :table, :columns, :primary_key, :comment) do
        def copy(schema: nil, table: nil, columns: nil, primary_key: nil, comment: nil)
          Table.new(schema || self.schema, table || self.table, columns || self.columns, primary_key || self.primary_key, comment || self.comment)
        end

        def same?(statement)
          schema == statement.schema && table == statement.table
        end
      end
      Column = Struct.new(:name, :type, :nullable, :default, :reference, :comment) do
        def copy(name: nil, type: nil, nullable: nil, default: nil, reference: nil, comment: nil)
          Column.new(name || self.name, type || self.type, nullable || self.nullable, default || self.default, reference || self.reference, comment || self.comment)
        end

        def same?(statement)
          name == statement.column
        end
      end
      Reference = Struct.new(:schema, :table, :column, :key_name)
      Structure = Struct.new(:tables) do
        def table(schema, table)
          tables.find { |t| t.schema == schema && t.table == table }
        end

        def column(schema, table, column)
          table(schema, table)&.columns&.find { |c| c.name == column }
        end

        def copy(tables: nil)
          Structure.new(tables || self.tables)
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

      class << self
        def parse_schema_file_r(path)
          read_lines_r(path).flat_map do |lines|
            statements = build_statements(lines)
            statements.inject(Result.of(Structure.new([]))) do |structure_r, statement|
              structure_r.flat_and(SqlParser.parse_statement_r(statement)) { |structure, parsed_statement| evolve_r(structure, parsed_statement) }
            end
          end
        end

        def build_statements(lines)
          useful_lines = lines.reject { |line| line.empty? || line.start_with?('--') }
          useful_lines.join(' ').gsub(/ +/, ' ').split(';').map { |s| "#{s.strip};" }
        end

        def evolve_r(structure, parsed_statement)
          case parsed_statement
          in SqlParser::Table => table
            columns = table.columns.map { |c| Column.new(c.name, c.type, c.nullable, c.default, nil, nil) }
            Result.of(structure.copy(tables: structure.tables + [Table.new(table.schema, table.table, columns, nil, nil)]))
          in SqlParser::TableComment => comment
            structure.update_table_r(comment) { |table| Result.of(table.copy(comment: comment.comment)) }
          in SqlParser::ColumnComment => comment
            structure.update_column_r(comment) { |column| Result.of(column.copy(comment: comment.comment)) }
          in SqlParser::PrimaryKey => pk
            structure.update_table_r(pk) { |table| Result.of(table.copy(primary_key: pk.columns)) }
          in SqlParser::ForeignKey => fk
            reference = Reference.new(fk.dest_schema, fk.dest_table, fk.dest_column, fk.name)
            structure.update_column_r(fk) { |column| Result.of(column.copy(reference: reference)) }
          in SqlParser::SetColumnDefault => default
            structure.update_column_r(default) { |column| Result.of(column.copy(default: default.value)) }
          else
            puts "not handled: #{parsed_statement.inspect}"
            Result.of(structure)
          end
        end

        def read_lines_r(path)
          Result.try do
            file = File.open(path)
            lines = file.readlines.map(&:chomp)
            file.close
            lines
          end
        end
      end

      module SqlParser
        Table = Struct.new(:schema, :table, :columns)
        Column = Struct.new(:name, :type, :nullable, :default)
        PrimaryKey = Struct.new(:schema, :table, :columns, :name)
        ForeignKey = Struct.new(:schema, :table, :column, :dest_schema, :dest_table, :dest_column, :name)
        SetColumnDefault = Struct.new(:schema, :table, :column, :value)
        SetColumnStatistics = Struct.new(:schema, :table, :column, :value)
        TableComment = Struct.new(:schema, :table, :comment)
        ColumnComment = Struct.new(:schema, :table, :column, :comment)

        class ParseError < StandardError
          def initialize(method, text, regex_result, cause)
            @text = text
            @cause = cause
            super("#{method} can't parse #{text.inspect}#{regex_result ? " (regex result: #{regex_result.inspect})" : ''}\nCaused by: #{cause.class}: #{cause.message}")
          end

          def backtrace
            @cause.backtrace
          end

          def add_context(method, text, regex_result)
            ParseError.new(method, text, regex_result, self)
          end
        end

        class << self
          def parse_statement_r(sql)
            return parse_table_r(sql) if sql.start_with?('CREATE TABLE')
            return parse_alter_table_r(sql) if sql.start_with?('ALTER TABLE')
            return parse_table_comment_r(sql) if sql.start_with?('COMMENT ON TABLE')
            return parse_column_comment_r(sql) if sql.start_with?('COMMENT ON COLUMN')
            Result.of(sql)
          end

          def parse_table_r(sql)
            r = /^CREATE TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) \((?<body>[^;]+?)\)(?: WITH \((?<options>.*?)\))?;$/
            res = sql.strip.gsub(/\n/, ' ').match(r)
            body_lines = split_on_comma_except_when_inside_parenthesis(res[:body]).map(&:strip)
            columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
            # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
            # options = res[:options].split(',')
            Result.seq(columns.map { |column| parse_column_r(column) })
                  .map { |parsed_columns| Table.new(res[:schema], res[:table], parsed_columns) }
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, sql, res, e))
          end

          def parse_column_r(sql)
            res = sql.match(/^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
            Result.of(Column.new(res[:name], res[:type], res[:nullable].nil?, res[:default]))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, sql, res, e))
          end

          def parse_alter_table_r(sql)
            res = sql.match(/ALTER TABLE ONLY (?<schema>[^ .]+)\.(?<table>[^ .]+) (?<command>.*);/)
            if res[:command].start_with?('ADD CONSTRAINT')
              parse_add_constraint_r(res[:schema], res[:table], res[:command]).on_error { |e| e.add_context(__method__, sql, res) }
            elsif res[:command].start_with?('ALTER COLUMN')
              parse_alter_column_r(res[:schema], res[:table], res[:command]).on_error { |e| e.add_context(__method__, sql, res) }
            else
              Result.failure(ParseError.new(__method__, sql, res, StandardError.new("Unknown command #{res[:command].inspect}")))
            end
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, sql, res, e))
          end

          def parse_add_constraint_r(schema, table, command)
            res = command.match(/ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)/)
            if res[:constraint].start_with?('PRIMARY KEY')
              parse_add_primary_key_r(schema, table, res[:name], res[:constraint]).on_error { |e| e.add_context(__method__, command, res) }
            elsif res[:constraint].start_with?('FOREIGN KEY')
              parse_add_foreign_key_r(schema, table, res[:name], res[:constraint]).on_error { |e| e.add_context(__method__, command, res) }
            else
              Result.failure(ParseError.new(__method__, command, res, StandardError.new("Unknown constraint #{res[:constraint].inspect}")))
            end
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, command, res, e))
          end

          def parse_add_primary_key_r(schema, table, name, constraint)
            res = constraint.match(/PRIMARY KEY \((?<columns>[^)]+)\)/)
            Result.of(PrimaryKey.new(schema, table, res[:columns].split(','), name))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, constraint, res, e))
          end

          def parse_add_foreign_key_r(schema, table, name, constraint)
            res = constraint.match(/FOREIGN KEY \((?<column>[^)]+)\) REFERENCES (?<dest_schema>[^ .]+)\.(?<dest_table>[^ .]+)\((?<dest_column>[^)]+)\)/)
            Result.of(ForeignKey.new(schema, table, res[:column], res[:dest_schema], res[:dest_table], res[:dest_column], name))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, constraint, res, e))
          end

          def parse_alter_column_r(schema, table, command)
            res = command.match(/ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)/)
            if res[:property].start_with?('DEFAULT')
              parse_alter_column_default_r(schema, table, res[:column], res[:property]).on_error { |e| e.add_context(__method__, command, res) }
            elsif res[:property].start_with?('STATISTICS')
              parse_alter_column_statistics_r(schema, table, res[:column], res[:property]).on_error { |e| e.add_context(__method__, command, res) }
            else
              Result.failure(ParseError.new(__method__, command, res, StandardError.new("Unknown property #{res[:property].inspect}")))
            end
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, command, res, e))
          end

          def parse_alter_column_default_r(schema, table, column, property)
            res = property.match(/DEFAULT (?<value>.+)/)
            Result.of(SetColumnDefault.new(schema, table, column, res[:value]))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, property, res, e))
          end

          def parse_alter_column_statistics_r(schema, table, column, property)
            res = property.match(/STATISTICS (?<value>[0-9]+)/)
            Result.of(SetColumnStatistics.new(schema, table, column, res[:value].to_i))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, property, res, e))
          end

          def parse_table_comment_r(sql)
            res = sql.match(/^COMMENT ON TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            Result.of(TableComment.new(res[:schema], res[:table], res[:comment].gsub(/''/, "'")))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, sql, res, e))
          end

          def parse_column_comment_r(sql)
            res = sql.match(/^COMMENT ON COLUMN (?<schema>[^ .]+)\.(?<table>[^ .]+)\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            Result.of(ColumnComment.new(res[:schema], res[:table], res[:column], res[:comment].gsub(/''/, "'")))
          rescue StandardError => e
            Result.failure(ParseError.new(__method__, sql, res, e))
          end

          # from https://stackoverflow.com/questions/18424315/how-do-i-split-a-string-by-commas-except-inside-parenthesis-using-a-regular-exp
          def split_on_comma_except_when_inside_parenthesis(text)
            text.scan(/(?:\([^()]*\)|[^,])+/)
          end
        end
      end
    end
  end
end
