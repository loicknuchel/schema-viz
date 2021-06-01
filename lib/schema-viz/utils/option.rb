# frozen_string_literal: true

require 'singleton'

module SchemaViz
  # Option represent a value which is optionally present
  # It allows to avoid nil and handle optional value presence consistently
  module Option
    class NoSuchElementError < StandardError
    end

    def self.of(value)
      value.nil? ? None.instance : Some.new(value)
    end

    def self.empty
      None.instance
    end

    def self.expected!(value)
      return value if value.is_a?(AbstractClass)
      raise TypeError, "expect Option, got #{value.inspect} (#{value.class})"
    end

    # Option abstract class, can be either a Some or a None. Don't extend it!
    class AbstractClass
      private_class_method :new, :allocate

      # using it is a smell, try to find dedicated methods instead
      def some?
        instance_of?(Some)
      end

      # use only in tests, prefer other methods such as `map`, `flat_map` or `get_or_else`
      def get!
        throw NotImplementedError
      end

      def get_or_else(default = nil)
        raise ArgumentError, 'expect block or value, not both' if block_given? && !default.nil?
        some? ? get! : block_given? ? yield : default
      end

      def map
        raise ArgumentError, 'a block is expected' unless block_given?
        some? ? Some.new(yield(get!)) : self
      end

      def flat_map
        raise ArgumentError, 'a block is expected' unless block_given?
        some? ? Option.expected!(yield(get!)) : self
      end

      def ==(other)
        self.class == other.class && (some? ? get! == other.get! : true)
      end
    end

    # presence case of Option
    class Some < AbstractClass
      public_class_method :new

      def initialize(value)
        super()
        @value = value
      end

      def get!
        @value
      end
    end

    # absence case of Option
    class None < AbstractClass
      include Singleton

      def get!
        raise NoSuchElementError
      end
    end
  end
end
