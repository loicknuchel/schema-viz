# frozen_string_literal: true

module SchemaViz
  class Matcher
    def initialize(text, regex)
      @text, @regex, @result = text, regex, Option.of(regex.match(text))
    end

    # matcher.get(key) -> Result<value or nil>
    def get(key)
      with_result("can't get #{key.inspect}") { |res| get_k(res, key) }
    end

    # matcher.slice(*keys) -> Result<array of values>
    def slice(*keys)
      with_result("can't slice #{keys.map(&:inspect).join(', ')}") { |res| Result.seq(keys.map { |key| get_k(res, key) }) }
    end

    def captures
      with_result { |res| Result.of(res.captures) }
    end

    private

    def with_result(msg = '')
      @result
        .map { |res| Result.expected!(yield(res)) }
        .get_or_else { Result.error(RuntimeError, "/#{@regex.source}/ didn't matched#{msg.empty? ? '' : ", #{msg}"}") }
    end

    def get_k(res, key)
      if key.instance_of?(Integer)
        get_i(res, key)
      elsif key.instance_of?(String)
        get_s(res, key)
      else
        Result.error(ArgumentError, "#{key.class} capture not supported (#{key.inspect})")
      end
    end

    def get_i(res, capture_index)
      captures = res.captures
      if capture_index < captures.length
        Result.of(captures[capture_index])
      else
        Result.error(ArgumentError, "#{capture_index.inspect} not captured, only #{captures.length - 1} captures")
      end
    end

    def get_s(res, capture_name)
      named_captures = res.named_captures
      if named_captures.key?(capture_name)
        Result.of(named_captures[capture_name])
      else
        Result.error(ArgumentError, "#{capture_name.inspect} not captured, captures: #{res.names.join(', ')}")
      end
    end
  end
end
