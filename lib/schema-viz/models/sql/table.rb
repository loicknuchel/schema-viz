# frozen_string_literal: true

module SchemaViz
  # model a SQL table
  class Table
    attr_reader :schema, :table, :columns

    def initialize(schema, table, columns)
      @schema, @table, @columns = schema, table, columns
    end

    def to_s
      "Table(#{schema}, #{table}, #{columns})"
    end

    def ==(other)
      self.class == other.class &&
        schema == other.schema &&
        table == other.table &&
        columns == other.columns
    end
  end
end
