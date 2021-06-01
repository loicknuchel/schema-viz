# frozen_string_literal: true

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
        Matcher = Struct.new(:text, :regex, :result) do
          def [](key)
            result.map do |res|
              if key.instance_of?(Integer)
                captures = res.captures
                raise "#{key.inspect} not captured, only #{captures.length - 1} captures" unless key < captures.length
                captures[key]
              elsif key.instance_of?(String) || key.instance_of?(Symbol)
                named_captures = res.named_captures
                raise "#{key.inspect} not captured, captures: #{res.name.join(', ')}" unless named_captures.key?(key.to_s)
                named_captures[key.to_s]
              else
                raise "#{key.class} capture not supported (#{key.inspect})"
              end
            end.get_or_else { raise "/#{regex.source}/ didn't matched, can't get #{key.inspect} capture" }
          end
        end

        # represent a parsing error with its context
        class ParseError < StandardError
          def initialize(method, matcher, cause)
            @cause = cause
            cause_class = cause.class.to_s.split('::').last
            super("#{method} can't parse #{matcher.text.inspect}\nCaused by: #{cause_class}: #{cause.message}")
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
            Result.of(sql)
          end

          def parse_table(sql)
            res = parse(sql, /^CREATE TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) \((?<body>[^;]+?)\)(?: WITH \((?<options>.*?)\))?;$/)
            begin
              body_lines = split_on_comma_except_when_inside_parenthesis(res[:body]).map(&:strip)
              columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
              # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
              # options = res[:options].split(',')
              Result.seq(columns.map { |column| parse_column(column) })
                    .map { |parsed_columns| Table.new(res[:schema], res[:table], parsed_columns) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, res, e))
            end
          end

          def parse_column(sql)
            res = parse(sql, /^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
            Result.rescue { Column.new(res[:name], res[:type], res[:nullable].nil?, Option.of(res[:default])) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_alter_table(sql)
            res = parse(sql, /ALTER TABLE (?:ONLY )?(?<schema>[^ .]+)\.(?<table>[^ .]+) (?<command>.*);/)
            begin
              if res[:command].start_with?('ADD CONSTRAINT')
                parse_add_constraint(res[:schema], res[:table], res[:command])
              elsif res[:command].start_with?('ALTER COLUMN')
                parse_alter_column(res[:schema], res[:table], res[:command])
              else
                Result.failure(StandardError.new("Unknown command #{res[:command].inspect}"))
              end.on_error { |e| ParseError.new(__method__, res, e) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, res, e))
            end
          end

          def parse_add_constraint(schema, table, command)
            res = parse(command, /ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)/)
            begin
              if res[:constraint].start_with?('PRIMARY KEY')
                parse_add_primary_key(schema, table, res[:name], res[:constraint])
              elsif res[:constraint].start_with?('FOREIGN KEY')
                parse_add_foreign_key(schema, table, res[:name], res[:constraint])
              elsif res[:constraint].start_with?('UNIQUE')
                parse_add_unique_constraint(schema, table, res[:name], res[:constraint])
              elsif res[:constraint].start_with?('CHECK')
                parse_add_check_constraint(schema, table, res[:name], res[:constraint])
              else
                Result.failure(StandardError.new("Unknown constraint #{res[:constraint]}"))
              end.on_error { |e| ParseError.new(__method__, res, e) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, res, e))
            end
          end

          def parse_add_primary_key(schema, table, name, constraint)
            res = parse(constraint, /PRIMARY KEY \((?<columns>[^)]+)\)/)
            Result.rescue { PrimaryKey.new(schema, table, res[:columns].split(',').map(&:strip), name) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_add_foreign_key(schema, table, name, constraint)
            res = parse(constraint, /FOREIGN KEY \((?<column>[^)]+)\) REFERENCES (?<dest_schema>[^ .]+)\.(?<dest_table>[^ .]+)\((?<dest_column>[^)]+)\)/)
            Result.rescue { ForeignKey.new(schema, table, res[:column], res[:dest_schema], res[:dest_table], res[:dest_column], name) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_add_unique_constraint(schema, table, name, constraint)
            res = parse(constraint, /UNIQUE \((?<columns>[^)]+)\)/)
            Result.rescue { UniqueConstraint.new(schema, table, res[:columns].split(',').map(&:strip), name) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_add_check_constraint(schema, table, name, constraint)
            res = parse(constraint, /CHECK (?<predicate>.*)/)
            Result.rescue { CheckConstraint.new(schema, table, res[:predicate], name) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_alter_column(schema, table, command)
            res = parse(command, /ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)/)
            begin
              if res[:property].start_with?('DEFAULT')
                parse_alter_column_default(schema, table, res[:column], res[:property])
              elsif res[:property].start_with?('STATISTICS')
                parse_alter_column_statistics(schema, table, res[:column], res[:property])
              else
                Result.failure(StandardError.new("Unknown property #{res[:property].inspect}"))
              end.on_error { |e| ParseError.new(__method__, res, e) }
            rescue StandardError => e
              Result.failure(ParseError.new(__method__, res, e))
            end
          end

          def parse_alter_column_default(schema, table, column, property)
            res = parse(property, /DEFAULT (?<value>.+)/)
            Result.rescue { SetColumnDefault.new(schema, table, column, res[:value]) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_alter_column_statistics(schema, table, column, property)
            res = parse(property, /STATISTICS (?<value>[0-9]+)/)
            Result.rescue { SetColumnStatistics.new(schema, table, column, res[:value].to_i) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_table_comment(sql)
            res = parse(sql, /^COMMENT ON TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            Result.rescue { TableComment.new(res[:schema], res[:table], res[:comment].gsub(/''/, "'")) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          def parse_column_comment(sql)
            res = parse(sql, /^COMMENT ON COLUMN (?<schema>[^ .]+)\.(?<table>[^ .]+)\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
            Result.rescue { ColumnComment.new(res[:schema], res[:table], res[:column], res[:comment].gsub(/''/, "'")) }
                  .on_error { |e| ParseError.new(__method__, res, e) }
          end

          # from https://stackoverflow.com/questions/18424315/how-do-i-split-a-string-by-commas-except-inside-parenthesis-using-a-regular-exp
          def split_on_comma_except_when_inside_parenthesis(text)
            text.scan(/(?:\([^()]*\)|[^,])+/)
          end

          def parse(text, regex)
            Matcher.new(text, regex, Option.of(regex.match(text)))
          end
        end
      end
    end
  end
end
