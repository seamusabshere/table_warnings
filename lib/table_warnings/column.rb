module TableWarnings
  class Column
    attr_reader :table
    attr_reader :name
    
    def initialize(table, name)
      @table = table
      @name = name
    end

    def nulls?(conditions)
      table.where(conditions).where(name => nil).count > 0
    end

    def string?
      table.columns_hash[name].try(:type) == :string
    end

    def blank?(conditions)
      table.where(conditions).where(["LENGTH(TRIM(#{table.quoted_table_name}.#{name})) = 0"]).count > 0
    end

    def values_outside?(min, max, conditions)
      t = table.arel_table
      range_conditions = if min and max
        t[name].lt(min).or(t[name].gt(max))
      elsif min
        t[name].lt(min)
      elsif max
        t[name].lt(max)
      else
        raise RuntimeError, "Either max or min or both should be defined"
      end
      table.where(conditions).where(range_conditions.and(t[name].not_eq(nil))).count > 0
    end

    def min
      table.minimum(name)
    end

    def max
      table.maximum(name)
    end
  end
end
