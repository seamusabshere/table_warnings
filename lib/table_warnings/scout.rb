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
      by_pattern = case pattern
      when Regexp
        !!(column_name =~ pattern)
      else
        column_name.to_s == pattern.to_s
      end
      if positive?
        by_pattern
      else
        !by_pattern
      end
    end

    def reserve?(column)
      match?(column) and (conditions? or specific?)
    end

    private

    def positive?
      @positive_query
    end

    def conditions?
      @conditions_query
    end

    def specific?
      !pattern.is_a? Regexp
    end
  end
end
