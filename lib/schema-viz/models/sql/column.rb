# frozen_string_literal: true

module SchemaViz
  # model a SQL column
  class Column
    attr_reader :name, :type, :nullable, :default

    def initialize(name, type, nullable, default)
      @name = name
      @type = type
      @nullable = nullable
      @default = default
    end

    def to_s
      "Column(#{name}, #{type}, #{nullable}, #{default})"
    end

    def ==(other)
      self.class == other.class &&
        name == other.name &&
        type == other.type &&
        nullable == other.nullable &&
        default == other.default
    end
  end
end
