# frozen_string_literal: true

module SchemaViz
  # Result represents a computation that may fail, using Success or Failure classes depending on the outcome
  # It allows to not raise errors that may pass several function levels and keep track of computation results
  module Result
    class NotASuccessError < StandardError
    end

    class NotAFailureError < StandardError
    end

    def self.of(value)
      Success.new(value)
    end

    def self.failure(error)
      Failure.new(error)
    end

    def self.error(error_class, msg = nil)
      error = error_class.new(msg)
      error.set_backtrace(caller)
      Failure.new(error)
    end

    def self.rescue
      raise TypeError, 'a block is expected' unless block_given?
      begin
        Success.new(yield)
      rescue StandardError => e
        Failure.new(e)
      end
    end

    def self.expected!(value)
      return value if value.is_a?(AbstractClass)
      raise TypeError, "expect Result, got #{value.inspect} (#{value.class})"
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
        Failure.new(errors.length == 1 ? errors.first : errors)
      end
    end

    # Result abstract class, can be either a Success or a Failure. Don't extend it!
    class AbstractClass
      private_class_method :new, :allocate

      # using it is a smell, try to find dedicated methods instead
      def success?
        instance_of?(Success)
      end

      # use only in tests, prefer other methods such as `map`, `flat_map`, `and`, `fold` or `get_or_else`
      def get!
        throw NotImplementedError
      end

      # use only in tests, prefer other methods such as `on_error`
      def error!
        throw NotImplementedError
      end

      def get_or_else(default = nil)
        raise ArgumentError, 'expect block or value, not both' if block_given? && !default.nil?
        success? ? get! : block_given? ? yield : default
      end

      def map
        raise TypeError, 'a block is expected' unless block_given?
        success? ? Result.rescue { yield(get!) } : self
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
          errors = results.select { |r| r.instance_of?(Failure) }.map(&:error!).flatten(1)
          Failure.new(errors.length == 1 ? errors.first : errors)
        end
      end

      def fold(on_failure, on_success)
        raise TypeError, "expect failure Proc for 1st param, got #{on_failure.inspect} (#{on_failure.class})" unless on_failure.instance_of?(Proc)
        raise TypeError, "expect success Proc for 2nd param, got #{on_success.inspect} (#{on_success.class})" unless on_success.instance_of?(Proc)
        success? ? on_success.call(get!) : on_failure.call(error!)
      end

      def ==(other)
        self.class == other.class && (success? ? get! == other.get! : error! == other.error!)
      end
    end

    # Success case of Result
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
        raise NotAFailureError, 'Result is in success'
      end
    end

    # Failure case of Result
    class Failure < AbstractClass
      public_class_method :new

      def initialize(error)
        super()
        @error = error
      end

      def get!
        raise NotASuccessError, 'No errors (empty array)' if @error.instance_of?(Array) && @error.empty?
        if @error.instance_of?(Array) && @error.length > 1
          raise NotASuccessError, "Multiple errors (#{@error.length}):#{@error.map { |e| "\n - #{e}" }.join}"
        end

        err = @error.instance_of?(Array) && @error.length == 1 ? @error[0] : @error
        raise err if err.is_a?(StandardError)
        raise NotASuccessError, err.to_s
      end

      def error!
        @error
      end
    end
  end
end
