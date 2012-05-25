module TableWarnings
  class Scout
    attr_reader :pattern
    attr_reader :conditions
    
    def initialize(pattern, options = {})
      @pattern = pattern
      @positive_query = (options[:negative] != true)
      @conditions_query = case options[:conditions]
      when String
        true
      when Hash, Array
        !options[:conditions].empty?
      else
        false
      end
    end

    def match?(column)
      column_name = column.name
      by_pattern = test column_name
      if positive?
        by_pattern
      else
        !by_pattern
      end
    end

    def cover?(column)
      column_name = column.name
      test column_name
    end

    def claim?(column)
      match?(column) and unambiguous?
    end

    private

    def test(str)
      case pattern
      when Regexp
        !!(str =~ pattern)
      else
        str.to_s == pattern.to_s
      end
    end

    def positive?
      @positive_query
    end

    def conditions?
      @conditions_query
    end

    def unambiguous?
      positive? and not pattern.is_a?(Regexp)
    end
  end
end
