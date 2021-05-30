# frozen_string_literal: true

module SchemaViz
  # to handle success/results of a computation and avoid raise
  module Result
    class NotASuccess < StandardError
    end

    class NotAFailure < StandardError
    end

    def self.of(value)
      Success.new(value)
    end

    def self.failure(error)
      Failure.new(error)
    end

    def self.try
      raise TypeError, 'a block is expected' unless block_given?

      begin
        Success.new(yield)
      rescue StandardError => e
        Failure.new(e)
      end
    end

    def self.expected!(value)
      raise TypeError, "expect Result, got #{value.inspect} (#{value.class})" unless value.is_a?(AbstractClass)

      value
    end

    # transform an Array of Result into a Result of Array
    def self.seq(arr)
      unless arr.all? { |r| r.is_a?(AbstractClass) }
        raise TypeError, "expect all items to be Result, invalid values: #{arr.reject { |r| r.is_a?(AbstractClass) }}"
      end

      errors = arr.select { |i| i.instance_of?(Failure) }.map(&:error!)
      if errors.empty?
        Success.new(arr.map { |i| i.instance_of?(Success) ? i.get! : i })
      else
        Failure.new(errors)
      end
    end

    # Result abstract class, can be either a Success or a Failure. Don't extend it!
    class AbstractClass
      private_class_method :new, :allocate

      def success?
        instance_of?(Success)
      end

      def get!
        throw NotImplementedError
      end

      def error!
        throw NotImplementedError
      end

      def map
        raise TypeError, 'a block is expected' unless block_given?

        success? ? Success.new(yield(get!)) : self
      end

      def flat_map
        raise TypeError, 'a block is expected' unless block_given?

        success? ? Result.expected!(yield(get!)) : self
      end

      def on_error
        raise TypeError, 'a block is expected' unless block_given?

        success? ? self : Failure.new(yield(error!))
      end

      def and(*others)
        raise TypeError, 'a block is expected' unless block_given?

        flat_and(*others) { |*args| Result.of(yield(*args)) }
      end

      def flat_and(*others)
        raise TypeError, 'a block is expected' unless block_given?

        results = [self] + others
        if results.all? { |r| r.instance_of?(Success) }
          Result.expected!(yield(*results.map(&:get!)))
        else
          errors = results.select { |r| r.instance_of?(Failure) }.map(&:error!)
          Failure.new(errors)
        end
      end

      def ==(other)
        self.class == other.class && (success? ? get! == other.get! : error! == other.error!)
      end
    end

    # Success case of the Result
    class Success < AbstractClass
      public_class_method :new

      def initialize(value)
        super()
        @value = value
      end

      def get!
        @value
      end

      def error!
        raise NotAFailure, 'Result is in success'
      end
    end

    # Failure case of the Result
    class Failure < AbstractClass
      public_class_method :new

      def initialize(error)
        super()
        @error = error
      end

      def get!
        raise @error if @error.is_a?(StandardError)

        raise NotASuccess, @error.to_s
      end

      def error!
        @error
      end
    end
  end
end
