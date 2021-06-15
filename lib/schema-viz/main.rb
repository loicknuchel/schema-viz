# frozen_string_literal: true

require './lib/schema-viz/sources/schema-file/service'
require './lib/schema-viz/target/writer'
require './lib/schema-viz/utils/args'
require './lib/schema-viz/utils/file'

module SchemaViz
  # Gem entry point, call it to use it
  module Main
    def self.main(args)
      args = Args.parse(args)
      if args.command.include?('generate') && args.has?(:structure) && args.has?(:output)
        structure_path = args.get_s!(:structure)
        output_path = args.get_s!(:output)
        file_service = File::Service.new
        structure_file_service = Source::SchemaFile::Service.new(file_service)
        writer_service = Target::Writer::Service.new(file_service)
        puts "Parsing #{structure_path.inspect} file..."
        structure_file_service.parse_schema_file(structure_path).on_error { |error| puts " -> error in parsing: #{error.message}" }.flat_map do |structure|
          puts " -> #{structure.tables.length} tables found"
          schema = format(structure)
          puts "Writing schema to #{output_path.inspect} file..."
          writer_service.write_schema_file(output_path, schema).on_error { |error| puts " -> error writing file: #{error.message}" }
        end.map do |length|
          puts " -> Done! Wrote #{length} chars."
        end
      else
        puts "invalid command"
      end

      true
    end

    private

    # the only code connecting sources and target models
    # takes a SchemaViz::Source::SchemaFile::Structure and returns a SchemaViz::Target::Writer::Schema
    def self.format(structure)
      SchemaViz::Target::Writer::Schema.new(structure.tables.map { |table| format_table(table) })
    end

    def self.format_table(table)
      SchemaViz::Target::Writer::Table.new(table.schema,
                                           table.table,
                                           table.columns.map { |column| format_column(column) },
                                           table.primary_key.map { |pk| format_primary_key(pk) }.get_or_nil,
                                           table.uniques.map { |unique| format_unique(unique) },
                                           [],
                                           table.comment.get_or_nil)
    end

    def self.format_column(column)
      SchemaViz::Target::Writer::Column.new(column.column,
                                            column.type,
                                            column.nullable,
                                            column.default.get_or_nil,
                                            column.reference.map { |fk| format_foreign_key(fk) }.get_or_nil,
                                            column.comment.get_or_nil)
    end

    def self.format_primary_key(pk)
      SchemaViz::Target::Writer::PrimaryKey.new(pk.columns, pk.name)
    end

    def self.format_foreign_key(fk)
      SchemaViz::Target::Writer::ForeignKey.new(fk.schema, fk.table, fk.column, fk.name)
    end

    def self.format_unique(unique)
      SchemaViz::Target::Writer::Unique.new(unique.columns, unique.name)
    end
  end
end
