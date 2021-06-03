# frozen_string_literal: true

require './lib/schema-viz/sources/schema-file/service'
require './lib/schema-viz/utils/args'
require './lib/schema-viz/utils/file'

module SchemaViz
  # Gem entry point, call it to use it
  module Main
    def self.main(args)
      args = Args.parse(args)
      if args.command.include?('generate')
        if args.has?(:structure)
          path = args.get_s(:structure)
          file_service = File::Service.new
          structure_file_service = Source::SchemaFile::Service.new(file_service)
          puts "Parsing #{path.inspect} file..."
          structure_r = structure_file_service.parse_schema_file(path)
          puts structure_r.fold(->(error) { " -> error in parsing: #{error.message}" },
                                ->(structure) { " -> #{structure.tables.length} tables found" })
        end
      end

      true
    end
  end
end
