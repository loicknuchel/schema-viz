# frozen_string_literal: true

require './lib/schema-viz/utils/result'

module SchemaViz
  module File
    # manipulate files
    class Service
      def read_lines_r(path)
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
