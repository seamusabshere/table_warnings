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
          "Foreign keys#{null_warning} refer to nonexistent values in #{column.name.inspect}"
        else
          "Foreign keys#{null_warning} refer to nonexistent values in #{column.name.inspect} given #{conditions.inspect}"
        end
      end
    end

    private

    def allow_null?
      @allow_null_query
    end

    def null_warning
      if not allow_null?
        ' are nil and/or'
      end
    end
  end
end