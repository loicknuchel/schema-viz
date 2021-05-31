# frozen_string_literal: true

require './lib/schema-viz/utils/result'

module SchemaViz
  # manipulate files
  class FileService
    def read_lines_r(path)
      file = File.open(path)
      begin
        Result.of(file.readlines.map(&:chomp))
      rescue StandardError => e
        Result.failure(e)
      ensure
        file.close
      end
    end
  end
end
