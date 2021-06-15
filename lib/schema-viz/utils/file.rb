# frozen_string_literal: true

require './lib/schema-viz/utils/result'

module SchemaViz
  module File
    Content = Struct.new(:file, :lines)
    Line = Struct.new(:file, :line, :text)

    # manipulate files
    class Service
      def read(path)
        read_raw_lines(path).map do |lines|
          Content.new(path, lines.each_with_index.map { |line, index| Line.new(path, index + 1, line) })
        end
      end

      def write(path, content)
        begin
          Result.of(::File.write(path, content))
        rescue StandardError => e
          Result.failure(e)
        end
      end

      def read_raw_lines(path)
        file = nil
        begin
          file = ::File.open(path)
          Result.of(file.readlines.map(&:chomp))
        rescue StandardError => e
          Result.failure(e)
        ensure
          file&.close
        end
      end
    end
  end
end
