# frozen_string_literal: true

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

        def update_table(statement)
          raise TableNotFound.from_statement(statement) if tables.find { |table| table.same?(statement) }.nil?
          copy(tables: tables.map { |table| table.same?(statement) ? yield(table) : table })
        end

        def update_column(statement)
          update_table(statement) do |table|
            raise ColumnNotFound.from_statement(statement) if table.columns.find { |column| column.same?(statement) }.nil?
            table.copy(columns: table.columns.map { |column| column.same?(statement) ? yield(column) : column })
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
        def parse_schema_file(path)
          lines = read_lines(path)
          statements = build_statements(lines)
          statements.inject(Structure.new([])) do |structure, statement|
            evolve(structure, SqlParser.parse_statement(statement))
          end
        end

        def build_statements(lines)
          useful_lines = lines.reject { |line| line.empty? || line.start_with?('--') }
          useful_lines.join(' ').gsub(/ +/, ' ').split(';').map { |s| "#{s.strip};" }
        end

        def evolve(structure, statement)
          case statement
          in SqlParser::Table => table
            columns = table.columns.map { |c| Column.new(c.name, c.type, c.nullable, c.default, nil, nil) }
            structure.copy(tables: structure.tables + [Table.new(table.schema, table.table, columns, nil, nil)])
          in SqlParser::TableComment => comment
            structure.update_table(comment) { |table| table.copy(comment: comment.comment) }
          in SqlParser::ColumnComment => comment
            structure.update_column(comment) { |column| column.copy(comment: comment.comment) }
          in SqlParser::PrimaryKey => pk
            structure.update_table(pk) { |table| table.copy(primary_key: pk.columns) }
          in SqlParser::ForeignKey => fk
            reference = Reference.new(fk.dest_schema, fk.dest_table, fk.dest_column, fk.name)
            structure.update_column(fk) { |column| column.copy(reference: reference) }
          else
            puts "not handled: #{statement.inspect}"
            structure
          end
        end

        def read_lines(path)
          file = File.open(path)
          lines = file.readlines.map(&:chomp)
          file.close
          lines
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
            super("#{method} can't parse #{text.inspect}#{regex_result ? "(result: #{regex_result.inspect})" : ''}\nCaused by: #{cause.class}: #{cause.message}")
          end

          def backtrace
            @cause.backtrace
          end
        end

        class << self
          def parse_statement(sql)
            return parse_table(sql) if sql.start_with?('CREATE TABLE')
            return parse_alter_table(sql) if sql.start_with?('ALTER TABLE')
            return parse_table_comment(sql) if sql.start_with?('COMMENT ON TABLE')
            return parse_column_comment(sql) if sql.start_with?('COMMENT ON COLUMN')
            sql
          end

          def parse_table(sql)
            r = /^CREATE TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) \((?<body>[^;]+?)\)(?: WITH \((?<options>.*?)\))?;$/
            res = sql.strip.gsub(/\n/, ' ').match(r)
            body_lines = split_on_comma_except_when_inside_parenthesis(res[:body]).map(&:strip)
            columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
            # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
            # options = res[:options].split(',')
            Table.new(res[:schema], res[:table], columns.map { |column| parse_column(column) })
          rescue StandardError => e
            raise ParseError.new(__method__, sql, res, e)
          end

          def parse_column(sql)
            res = sql.match(/^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
            Column.new(res[:name], res[:type], res[:nullable].nil?, res[:default])
          rescue StandardError => e
            raise ParseError.new(__method__, sql, res, e)
          end

          def parse_alter_table(sql)
            res = sql.match(/ALTER TABLE ONLY (?<schema>[^ .]+)\.(?<table>[^ .]+) (?<command>.*);/)
            if res[:command].start_with?('ADD CONSTRAINT')
              parse_add_constraint(res[:schema], res[:table], res[:command])
            elsif res[:command].start_with?('ALTER COLUMN')
              parse_alter_column(res[:schema], res[:table], res[:command])
            else
              raise 'error'
            end
          rescue StandardError => e
            raise ParseError.new(__method__, sql, res, e)
          end

          def parse_add_constraint(schema, table, command)
            res = command.match(/ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)/)
            if res[:constraint].start_with?('PRIMARY KEY')
              parse_add_primary_key(schema, table, res[:name], res[:constraint])
            elsif res[:constraint].start_with?('FOREIGN KEY')
              parse_add_foreign_key(schema, table, res[:name], res[:constraint])
            else
              raise 'error'
            end
          rescue StandardError => e
            raise ParseError.new(__method__, command, res, e)
          end

          def parse_add_primary_key(schema, table, name, constraint)
            res = constraint.match(/PRIMARY KEY \((?<columns>[^)]+)\)/)
            PrimaryKey.new(schema, table, res[:columns].split(','), name)
          rescue StandardError => e
            raise ParseError.new(__method__, constraint, res, e)
          end

          def parse_add_foreign_key(schema, table, name, constraint)
            res = constraint.match(/FOREIGN KEY \((?<column>[^)]+)\) REFERENCES (?<dest_schema>[^ .]+)\.(?<dest_table>[^ .]+)\((?<dest_column>[^)]+)\)/)
            ForeignKey.new(schema, table, res[:column], res[:dest_schema], res[:dest_table], res[:dest_column], name)
          rescue StandardError => e
            raise ParseError.new(__method__, constraint, res, e)
          end

          def parse_alter_column(schema, table, command)
            res = command.match(/ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)/)
            if res[:property].start_with?('DEFAULT')
              parse_alter_column_default(schema, table, res[:column], res[:property])
            elsif res[:property].start_with?('STATISTICS')
              parse_alter_column_statistics(schema, table, res[:column], res[:property])
            else
              raise 'error'
            end
          rescue StandardError => e
            raise ParseError.new(__method__, command, res, e)
          end

          def parse_alter_column_default(schema, table, column, property)
            res = property.match(/DEFAULT (?<value>.+)/)
            SetColumnDefault.new(schema, table, column, res[:value])
          rescue StandardError => e
            raise ParseError.new(__method__, property, res, e)
          end

          def parse_alter_column_statistics(schema, table, column, property)
            res = property.match(/STATISTICS (?<value>[0-9]+)/)
            SetColumnStatistics.new(schema, table, column, res[:value].to_i)
          rescue StandardError => e
            raise ParseError.new(__method__, property, res, e)
          end

          def parse_table_comment(sql)
            res = sql.match(/^COMMENT ON TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            TableComment.new(res[:schema], res[:table], res[:comment].gsub(/''/, "'"))
          rescue StandardError => e
            raise ParseError.new(__method__, sql, res, e)
          end

          def parse_column_comment(sql)
            res = sql.match(/^COMMENT ON COLUMN (?<schema>[^ .]+)\.(?<table>[^ .]+)\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            ColumnComment.new(res[:schema], res[:table], res[:column], res[:comment].gsub(/''/, "'"))
          rescue StandardError => e
            raise ParseError.new(__method__, sql, res, e)
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
