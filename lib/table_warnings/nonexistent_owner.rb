module TableWarnings
  class NonexistentOwner < Exclusive
    def initialize(table, matcher, options = {})
      super
      scout.enable_association_check!
      @allow_null_query = options[:allow_null]
    end

    def message(column)
      if column.nonexistent_owners?(conditions) or (not allow_null? and column.nulls?(conditions))
        if conditions.empty?
          "Values in foreign key column #{column.name.inspect}#{null_warning} do not correspond to actual values in foreign table."
        else
          "Values in foreign key column #{column.name.inspect} under condition #{conditions.inspect}#{null_warning} do not correspond to actual values in foreign table."
        end
      end
    end

    private

    def allow_null?
      @allow_null_query
    end

    def null_warning
      if not allow_null?
        ' are NULL and/or'
      end
    end
  end
end