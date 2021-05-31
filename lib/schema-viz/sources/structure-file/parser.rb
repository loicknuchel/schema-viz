# frozen_string_literal: true

require './lib/schema-viz/utils/result'

module SchemaViz
  module Source
    module StructureFile
      # parse SQL statements
      module Parser
        Table = Struct.new(:schema, :table, :columns)
        Column = Struct.new(:column, :type, :nullable, :default)
        PrimaryKey = Struct.new(:schema, :table, :columns, :name)
        ForeignKey = Struct.new(:schema, :table, :column, :dest_schema, :dest_table, :dest_column, :name)
        UniqueConstraint = Struct.new(:schema, :table, :columns, :name)
        CheckConstraint = Struct.new(:schema, :table, :predicate, :name)
        SetColumnDefault = Struct.new(:schema, :table, :column, :value)
        SetColumnStatistics = Struct.new(:schema, :table, :column, :value)
        TableComment = Struct.new(:schema, :table, :comment)
        ColumnComment = Struct.new(:schema, :table, :column, :comment)

        # represent a parsing error with its context
        class ParseError < StandardError
          def initialize(method, text, regex_result, cause)
            @text = text
            @cause = cause
            regex_text = regex_result ? " (regex result: #{regex_result.inspect})" : ''
            super("#{method} can't parse #{text.inspect}#{regex_text}\nCaused by: #{cause.class}: #{cause.message}")
          end

          def backtrace
            @cause.backtrace
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
            res = sql.match(/^CREATE TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) \((?<body>[^;]+?)\)(?: WITH \((?<options>.*?)\))?;$/)
            begin
              body_lines = split_on_comma_except_when_inside_parenthesis(res[:body]).map(&:strip)
              columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
              # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
              # options = res[:options].split(',')
              Result.seq(columns.map { |column| parse_column_r(column) })
                    .map { |parsed_columns| Table.new(res[:schema], res[:table], parsed_columns) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, sql, res, e))
            end
          end

          def parse_column_r(sql)
            res = sql.match(/^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
            Result.rescue { Column.new(res[:name], res[:type], res[:nullable].nil?, res[:default]) }
                  .on_error { |e| ParseError.new(__method__, sql, res, e) }
          end

          def parse_alter_table_r(sql)
            res = sql.match(/ALTER TABLE (?:ONLY )?(?<schema>[^ .]+)\.(?<table>[^ .]+) (?<command>.*);/)
            begin
              if res[:command].start_with?('ADD CONSTRAINT')
                parse_add_constraint_r(res[:schema], res[:table], res[:command])
              elsif res[:command].start_with?('ALTER COLUMN')
                parse_alter_column_r(res[:schema], res[:table], res[:command])
              else
                Result.failure(StandardError.new("Unknown command #{res[:command].inspect}"))
              end.on_error { |e| ParseError.new(__method__, sql, res, e) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, sql, res, e))
            end
          end

          def parse_add_constraint_r(schema, table, command)
            res = command.match(/ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)/)
            begin
              if res[:constraint].start_with?('PRIMARY KEY')
                parse_add_primary_key_r(schema, table, res[:name], res[:constraint])
              elsif res[:constraint].start_with?('FOREIGN KEY')
                parse_add_foreign_key_r(schema, table, res[:name], res[:constraint])
              elsif res[:constraint].start_with?('UNIQUE')
                parse_add_unique_constraint_r(schema, table, res[:name], res[:constraint])
              elsif res[:constraint].start_with?('CHECK')
                parse_add_check_constraint_r(schema, table, res[:name], res[:constraint])
              else
                Result.failure(StandardError.new("Unknown constraint #{res[:constraint]}"))
              end.on_error { |e| ParseError.new(__method__, command, res, e) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, command, res, e))
            end
          end

          def parse_add_primary_key_r(schema, table, name, constraint)
            res = constraint.match(/PRIMARY KEY \((?<columns>[^)]+)\)/)
            Result.rescue { PrimaryKey.new(schema, table, res[:columns].split(',').map(&:strip), name) }
                  .on_error { |e| ParseError.new(__method__, constraint, res, e) }
          end

          def parse_add_foreign_key_r(schema, table, name, constraint)
            res = constraint.match(/FOREIGN KEY \((?<column>[^)]+)\) REFERENCES (?<dest_schema>[^ .]+)\.(?<dest_table>[^ .]+)\((?<dest_column>[^)]+)\)/)
            Result.rescue { ForeignKey.new(schema, table, res[:column], res[:dest_schema], res[:dest_table], res[:dest_column], name) }
                  .on_error { |e| ParseError.new(__method__, constraint, res, e) }
          end

          def parse_add_unique_constraint_r(schema, table, name, constraint)
            res = constraint.match(/UNIQUE \((?<columns>[^)]+)\)/)
            Result.rescue { UniqueConstraint.new(schema, table, res[:columns].split(',').map(&:strip), name) }
                  .on_error { |e| ParseError.new(__method__, constraint, res, e) }
          end

          def parse_add_check_constraint_r(schema, table, name, constraint)
            res = constraint.match(/CHECK (?<predicate>.*)/)
            Result.rescue { CheckConstraint.new(schema, table, res[:predicate], name) }
                  .on_error { |e| ParseError.new(__method__, constraint, res, e) }
          end

          def parse_alter_column_r(schema, table, command)
            res = command.match(/ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)/)
            begin
              if res[:property].start_with?('DEFAULT')
                parse_alter_column_default_r(schema, table, res[:column], res[:property])
              elsif res[:property].start_with?('STATISTICS')
                parse_alter_column_statistics_r(schema, table, res[:column], res[:property])
              else
                Result.failure(StandardError.new("Unknown property #{res[:property].inspect}"))
              end.on_error { |e| ParseError.new(__method__, command, res, e) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, command, res, e))
            end
          end

          def parse_alter_column_default_r(schema, table, column, property)
            res = property.match(/DEFAULT (?<value>.+)/)
            Result.rescue { SetColumnDefault.new(schema, table, column, res[:value]) }
                  .on_error { |e| ParseError.new(__method__, property, res, e) }
          end

          def parse_alter_column_statistics_r(schema, table, column, property)
            res = property.match(/STATISTICS (?<value>[0-9]+)/)
            Result.rescue { SetColumnStatistics.new(schema, table, column, res[:value].to_i) }
                  .on_error { |e| ParseError.new(__method__, property, res, e) }
          end

          def parse_table_comment_r(sql)
            res = sql.match(/^COMMENT ON TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            Result.rescue { TableComment.new(res[:schema], res[:table], res[:comment].gsub(/''/, "'")) }
                  .on_error { |e| ParseError.new(__method__, sql, res, e) }
          end

          def parse_column_comment_r(sql)
            res = sql.match(/^COMMENT ON COLUMN (?<schema>[^ .]+)\.(?<table>[^ .]+)\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            Result.rescue { ColumnComment.new(res[:schema], res[:table], res[:column], res[:comment].gsub(/''/, "'")) }
                  .on_error { |e| ParseError.new(__method__, sql, res, e) }
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
