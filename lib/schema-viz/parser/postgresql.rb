# frozen_string_literal: true

module SchemaViz
  module Parser
    # parse a PostgreSQL file
    module Postgresql
      class << self
        def parse_table(sql)
          res = sql.gsub(/\n/, ' ').match(/CREATE TABLE (?<schema>[^ .]+).(?<table>[^ ]+) \((?<body>[^;]+)\);/)
          body_lines = res[:body].split(',').map(&:strip)
          columns = body_lines.reject { |line| line.start_with?('CONSTRAINT') }
          # constraints = body_lines.select { |line| line.start_with?('CONSTRAINT') }
          Table.new(res[:schema], res[:table], columns.map { |column| parse_column(column) })
        end

        def parse_column(sql)
          res = sql.match(/^(?<name>[^ ]+) (?<type>.*?)(?: DEFAULT (?<default>.*?))?(?<nullable> NOT NULL)?$/)
          Column.new(res[:name], res[:type], res[:nullable].nil?, res[:default])
        end
      end
    end
  end
end
