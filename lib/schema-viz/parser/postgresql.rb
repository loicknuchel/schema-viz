# frozen_string_literal: true

module SchemaViz
  module Parser
    # parse a PostgreSQL file
    module Postgresql
      TableComment = Struct.new(:schema, :table, :comment)
      ColumnComment = Struct.new(:schema, :table, :column, :comment)
      Table = Struct.new(:schema, :table, :columns)
      Column = Struct.new(:name, :type, :nullable, :default)
      PrimaryKey = Struct.new(:schema, :table, :columns, :name)
      ForeignKey = Struct.new(:schema, :table, :column, :dest_schema, :dest_table, :dest_column, :name)
      SetColumnDefault = Struct.new(:schema, :table, :column, :value)
      SetColumnStatistics = Struct.new(:schema, :table, :column, :value)

      class << self
        def parse_schema_file(path)
          file = File.open(path)
          lines = file.readlines.map(&:chomp)
          file.close
          useful_lines = lines.reject { |line| line.empty? || line.start_with?('--') }
          statements = useful_lines.join(' ').gsub(/ +/, ' ').split(';').map { |s| "#{s.strip};" }
          statements.select { |s| s.start_with?('CREATE TABLE') }.map { |s| parse_table(s) }
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

        private

        # from https://stackoverflow.com/questions/18424315/how-do-i-split-a-string-by-commas-except-inside-parenthesis-using-a-regular-exp
        def split_on_comma_except_when_inside_parenthesis(text)
          text.scan(/(?:\([^()]*\)|[^,])+/)
        end
      end
    end
  end
end
