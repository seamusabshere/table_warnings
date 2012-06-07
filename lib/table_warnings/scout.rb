module TableWarnings
  class Scout
    attr_reader :table
    attr_reader :matcher
    attr_reader :conditions
    
    def initialize(table, matcher, options = {})
      @table = table
      @matcher = matcher
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

    def exclusive?(column)
      match?(column) and unambiguous?
    end

    def match?(column)
      if association_check? and not column.association
        return false
      end
      if positive?
        cover? column
      else
        not cover?(column)
      end
    end

    def cover?(column)
      column_name = column.name
      if association_check?
        associations.any? do |a|
          a.foreign_key == column_name
        end
      else
        case matcher
        when Regexp
          !!(column_name =~ matcher)
        else
          column_name.to_s == matcher.to_s
        end
      end
    end

    def enable_association_check!
      @association_check_query = true
    end

    private

    def association_check?
      @association_check_query
    end

    def associations
      @associations ||= case matcher
      when Regexp
        table.reflect_on_all_associations(:belongs_to).select do |a|
          a.foreign_key =~ matcher
        end
      else
        [ table.reflect_on_association(matcher) ]
      end
    end

    def positive?
      @positive_query
    end

    def conditions?
      @conditions_query
    end

    def unambiguous?
      positive? and not matcher.is_a?(Regexp)
    end
  end
end
