# frozen_string_literal: true

module SchemaViz
  module Parser
    # parse a PostgreSQL file
    module Postgresql
      Table = Struct.new(:schema, :table, :columns, :comment)
      Column = Struct.new(:name, :type, :nullable, :default, :reference, :comment)
      Reference = Struct.new(:schema, :table, :column, :key_name)
      Structure = Struct.new(:tables) do
        def table(schema, table)
          tables.find { |t| t.schema == schema && t.table == table }
        end

        def column(schema, table, column)
          table(schema, table)&.columns&.find { |c| c.name == column }
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
            Structure.new(structure.tables + [Table.new(table.schema, table.table, columns, nil)])
          in SqlParser::TableComment => comment
            Structure.new(add_table_comment(structure.tables, comment))
          in SqlParser::ColumnComment => comment
            Structure.new(add_column_comment(structure.tables, comment))
          in SqlParser::ForeignKey => fk
            Structure.new(add_foreign_key(structure.tables, fk))
          else
            puts "not handled: #{statement.inspect}"
            structure
          end
        end

        def add_table_comment(tables, comment)
          update_table(tables, comment) { |table| Table.new(table.schema, table.table, table.columns, comment.comment) }
        end

        def add_column_comment(tables, comment)
          update_column(tables, comment) do |c|
            Column.new(c.name, c.type, c.nullable, c.default, c.reference, comment.comment)
          end
        end

        def add_foreign_key(tables, fk)
          update_column(tables, fk) do |c|
            reference = Reference.new(fk.dest_schema, fk.dest_table, fk.dest_column, fk.name)
            Column.new(c.name, c.type, c.nullable, c.default, reference, c.comment)
          end
        end

        def update_table(tables, statement)
          raise 'error' if tables.find { |t| same_table?(t, statement) }.nil?
          tables.map { |table| same_table?(table, statement) ? yield(table) : table }
        end

        def update_column(tables, statement)
          update_table(tables, statement) do |table|
            raise 'error' if table.columns.find { |c| same_column?(c, statement) }.nil?
            Table.new(table.schema, table.table, table.columns.map do |c|
              same_column?(c, statement) ? yield(c) : c
            end, table.comment)
          end
        end

        def same_table?(table, statement)
          table.schema == statement.schema && table.table == statement.table
        end

        def same_column?(column, statement)
          column.name == statement.column
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
            puts "parse_table failed on #{sql.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_column(sql)
            res = sql.match(/^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
            Column.new(res[:name], res[:type], res[:nullable].nil?, res[:default])
          rescue StandardError => e
            puts "parse_column failed on #{sql.inspect} (res: #{res.inspect})"
            raise e
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
            puts "parse_alter_table failed on #{sql.inspect} (res: #{res.inspect})"
            raise e
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
            puts "parse_add_constraint failed on #{command.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_add_primary_key(schema, table, name, constraint)
            res = constraint.match(/PRIMARY KEY \((?<columns>[^)]+)\)/)
            PrimaryKey.new(schema, table, res[:columns].split(','), name)
          rescue StandardError => e
            puts "parse_add_primary_key failed on #{constraint.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_add_foreign_key(schema, table, name, constraint)
            res = constraint.match(/FOREIGN KEY \((?<column>[^)]+)\) REFERENCES (?<dest_schema>[^ .]+)\.(?<dest_table>[^ .]+)\((?<dest_column>[^)]+)\)/)
            ForeignKey.new(schema, table, res[:column], res[:dest_schema], res[:dest_table], res[:dest_column], name)
          rescue StandardError => e
            puts "parse_add_foreign_key failed on #{constraint.inspect} (res: #{res.inspect})"
            raise e
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
            puts "parse_alter_column failed on #{command.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_alter_column_default(schema, table, column, property)
            res = property.match(/DEFAULT (?<value>.+)/)
            SetColumnDefault.new(schema, table, column, res[:value])
          rescue StandardError => e
            puts "parse_alter_column_default failed on #{property.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_alter_column_statistics(schema, table, column, property)
            res = property.match(/STATISTICS (?<value>[0-9]+)/)
            SetColumnStatistics.new(schema, table, column, res[:value].to_i)
          rescue StandardError => e
            puts "parse_alter_column_statistics failed on #{property.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_table_comment(sql)
            res = sql.match(/^COMMENT ON TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            TableComment.new(res[:schema], res[:table], res[:comment].gsub(/''/, "'"))
          rescue StandardError => e
            puts "parse_table_comment failed on #{sql.inspect} (res: #{res.inspect})"
            raise e
          end

          def parse_column_comment(sql)
            res = sql.match(/^COMMENT ON COLUMN (?<schema>[^ .]+)\.(?<table>[^ .]+)\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            ColumnComment.new(res[:schema], res[:table], res[:column], res[:comment].gsub(/''/, "'"))
          rescue StandardError => e
            puts "parse_column_comment failed on #{sql.inspect} (res: #{res.inspect})"
            raise e
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
