# frozen_string_literal: true

module SchemaViz
  module Target
    module Writer
      # these models mimic the json structure to have the simplest serializer possible
      Schema = Struct.new(:tables) do
        def to_h
          { tables: tables.map(&:to_h) }
        end
      end
      Table = Struct.new(:schema, :table, :columns, :primary_key, :uniques, :indexes, :comment) do
        def to_h
          { schema: schema, table: table, columns: columns.map(&:to_h), primary_key: primary_key&.to_h, uniques: uniques.map(&:to_h), indexes: indexes.map(&:to_h), comment: comment }.compact
        end
      end
      Column = Struct.new(:column, :type, :nullable, :default, :reference, :comment) do
        def to_h
          { column: column, type: type, nullable: nullable, default: default, reference: reference&.to_h, comment: comment }.compact
        end
      end
      PrimaryKey = Struct.new(:columns, :name)
      ForeignKey = Struct.new(:schema, :table, :column, :name)
      Unique = Struct.new(:columns, :name)
      Index = Struct.new(:columns, :definition, :name)

      class Service
        def initialize(file_service)
          @file_service = file_service
        end

        # takes a String path and write the SchemaViz::Target::Writer::Schema schema into the file, returns a SchemaViz::Result<Int>
        def write_schema_file(path, schema)
          @file_service.write(path, to_json(schema) + "\n")
        end

        def to_json(schema)
          require 'json'
          JSON.pretty_generate(schema.to_h)
        end
      end
    end
  end
end
