# frozen_string_literal: true

module SchemaViz
  module Parser
    # parse a PostgreSQL file
    module Postgresql
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
          r = /CREATE TABLE (?<schema>[^ .]+).(?<table>[^ ]+) \((?<body>[^;]+?)\)(?: WITH \((?<options>.*?)\))?;/
          res = sql.gsub(/\n/, ' ').match(r)
          body_lines = split_on_comma_except_when_inside_parenthesis(res[:body]).map(&:strip)
          columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
          # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
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

        private

        # from https://stackoverflow.com/questions/18424315/how-do-i-split-a-string-by-commas-except-inside-parenthesis-using-a-regular-exp
        def split_on_comma_except_when_inside_parenthesis(text)
          text.scan(/(?:\([^()]*\)|[^,])+/)
        end
      end
    end
  end
end
