# frozen_string_literal: true

require './lib/schema/viz/version'

module Schema
  # Gem entry point, call it to use it
  module Viz
    class Error < StandardError; end

    def self.main(args)
      puts "Hello Viz: #{args}"
    end
  end
end
