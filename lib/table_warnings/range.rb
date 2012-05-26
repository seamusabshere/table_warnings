module TableWarnings
  class Range < Exclusive
    attr_reader :max
    attr_reader :min

    def initialize(table, matcher, options = {})
      super
      @min = options[:min]
      @max = options[:max]
      @allow_null_query = options[:allow_null]
      if min and max and min > max
        raise ArgumentError, "Min #{min.inspect} must be less than max #{max.inspect}"
      end
    end

    def message(column)
      if column.values_outside?(min, max, conditions) or (not allow_null? and column.nulls?(conditions))
        if conditions.empty?
          "Unexpected range for #{column.name.inspect}. Min: #{column.min.inspect} (expected #{min.inspect}) Max: #{column.max.inspect} (expected #{max.inspect})"
        else
          "Unexpected range for #{column.name.inspect} in #{conditions.inspect}. Min: #{column.min.inspect} (expected #{min.inspect}) Max: #{column.max.inspect} (expected #{max.expect})"
        end
      end
    end

    private

    def allow_null?
      @allow_null_query
    end
  end
end
