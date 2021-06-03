# frozen_string_literal: true

require './lib/schema-viz/utils/matcher'

module SchemaViz
  module Source
    module SchemaFile
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
          def initialize(method, text, cause)
            @backtrace = cause.backtrace
            cause_class = cause.class.to_s.split('::').last
            super("#{method} can't parse #{text.inspect}\nCaused by: #{cause_class}: #{cause.message}")
          end

          def backtrace
            @backtrace
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
            Matcher.new(sql, /^CREATE TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) \((?<body>[^;]+?)\)(?: WITH \((?<options>.*?)\))?;$/)
                   .slice('schema', 'table', 'body', 'options')
                   .flat_map do |schema, table, body, _options|
              body_lines = nested_comma_split(body).map(&:strip)
              columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
              # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
              # options = options.split(',')
              Result.seq(columns.map { |column| parse_column(column) })
                    .map { |parsed_columns| Table.new(schema, table, parsed_columns) }
            end.on_error { |e| ParseError.new(__method__, sql, e) }
          end

          def parse_column(sql)
            Matcher.new(sql, /^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
                   .slice('name', 'type', 'nullable', 'default')
                   .map { |name, type, nullable, default| Column.new(name, type, nullable.nil?, Option.of(default)) }
                   .on_error { |e| ParseError.new(__method__, sql, e) }
          end

          def parse_alter_table(sql)
            Matcher.new(sql, /ALTER TABLE (?:ONLY )?(?<schema>[^ .]+)\.(?<table>[^ .]+) (?<command>.*);/)
                   .slice('schema', 'table', 'command')
                   .flat_map do |schema, table, command|
              if command.start_with?('ADD CONSTRAINT')
                parse_add_constraint(schema, table, command)
              elsif command.start_with?('ALTER COLUMN')
                parse_alter_column(schema, table, command)
              else
                Result.failure(StandardError.new("Unknown command #{command.inspect}"))
              end
            end.on_error { |e| ParseError.new(__method__, sql, e) }
          end

          def parse_add_constraint(schema, table, command)
            Matcher.new(command, /ADD CONSTRAINT (?<name>[^ .]+) (?<constraint>.*)/)
                   .slice('name', 'constraint')
                   .flat_map do |name, constraint|
              if constraint.start_with?('PRIMARY KEY')
                parse_add_primary_key(schema, table, name, constraint)
              elsif constraint.start_with?('FOREIGN KEY')
                parse_add_foreign_key(schema, table, name, constraint)
              elsif constraint.start_with?('UNIQUE')
                parse_add_unique_constraint(schema, table, name, constraint)
              elsif constraint.start_with?('CHECK')
                parse_add_check_constraint(schema, table, name, constraint)
              else
                Result.failure(StandardError.new("Unknown constraint #{constraint}"))
              end
            end.on_error { |e| ParseError.new(__method__, command, e) }
          end

          def parse_add_primary_key(schema, table, name, constraint)
            Matcher.new(constraint, /PRIMARY KEY \((?<columns>[^)]+)\)/)
                   .get('columns').map { |columns| columns.split(',').map(&:strip) }
                   .map { |columns| PrimaryKey.new(schema, table, columns, name) }
                   .on_error { |e| ParseError.new(__method__, constraint, e) }
          end

          def parse_add_foreign_key(schema, table, name, constraint)
            Matcher.new(constraint, /FOREIGN KEY \((?<column>[^)]+)\) REFERENCES (?<schema_b>[^ .]+)\.(?<table_b>[^ .]+)\((?<column_b>[^)]+)\)/)
                   .slice('column', 'schema_b', 'table_b', 'column_b')
                   .map { |column, schema_b, table_b, column_b| ForeignKey.new(schema, table, column, schema_b, table_b, column_b, name) }
                   .on_error { |e| ParseError.new(__method__, constraint, e) }
          end

          def parse_add_unique_constraint(schema, table, name, constraint)
            Matcher.new(constraint, /UNIQUE \((?<columns>[^)]+)\)/)
                   .get('columns').map { |columns| columns.split(',').map(&:strip) }
                   .map { |columns| UniqueConstraint.new(schema, table, columns, name) }
                   .on_error { |e| ParseError.new(__method__, constraint, e) }
          end

          def parse_add_check_constraint(schema, table, name, constraint)
            Matcher.new(constraint, /CHECK (?<predicate>.*)/)
                   .get('predicate')
                   .map { |predicate| CheckConstraint.new(schema, table, predicate, name) }
                   .on_error { |e| ParseError.new(__method__, constraint, e) }
          end

          def parse_alter_column(schema, table, command)
            Matcher.new(command, /ALTER COLUMN (?<column>[^ .]+) SET (?<property>.+)/)
                   .slice('column', 'property')
                   .flat_map do |column, property|
              if property.start_with?('DEFAULT')
                parse_alter_column_default(schema, table, column, property)
              elsif property.start_with?('STATISTICS')
                parse_alter_column_statistics(schema, table, column, property)
              else
                Result.failure(StandardError.new("Unknown property #{property.inspect}"))
              end
            end.on_error { |e| ParseError.new(__method__, command, e) }
          end

          def parse_alter_column_default(schema, table, column, property)
            Matcher.new(property, /DEFAULT (?<value>.+)/)
                   .get('value')
                   .map { |value| SetColumnDefault.new(schema, table, column, value) }
                   .on_error { |e| ParseError.new(__method__, property, e) }
          end

          def parse_alter_column_statistics(schema, table, column, property)
            Matcher.new(property, /STATISTICS (?<value>[0-9]+)/)
                   .get('value').map(&:to_i)
                   .map { |value| SetColumnStatistics.new(schema, table, column, value) }
                   .on_error { |e| ParseError.new(__method__, property, e) }
          end

          def parse_table_comment(sql)
            Matcher.new(sql, /^COMMENT ON TABLE (?<schema>[^ .]+)\.(?<table>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
                   .slice('schema', 'table', 'comment')
                   .map { |schema, table, comment| TableComment.new(schema, table, comment.gsub(/''/, "'")) }
                   .on_error { |e| ParseError.new(__method__, sql, e) }
          end

          def parse_column_comment(sql)
            Matcher.new(sql, /^COMMENT ON COLUMN (?<schema>[^ .]+)\.(?<table>[^ .]+)\.(?<column>[^ .]+) IS '(?<comment>(?:[^']|'')+)';$/)
                   .slice('schema', 'table', 'column', 'comment')
                   .map { |schema, table, column, comment| ColumnComment.new(schema, table, column, comment.gsub(/''/, "'")) }
                   .on_error { |e| ParseError.new(__method__, sql, e) }
          end

          # from https://stackoverflow.com/questions/18424315/how-do-i-split-a-string-by-commas-except-inside-parenthesis-using-a-regular-exp
          def nested_comma_split(text)
            text.scan(/(?:\([^()]*\)|[^,])+/)
          end
        end
      end
    end
  end
end
