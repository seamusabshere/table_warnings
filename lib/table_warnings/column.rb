module TableWarnings
  class Column
    attr_reader :table
    attr_reader :name
    
    def initialize(table, name)
      @table = table
      @name = name.to_s
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

    # select zip_codes.* from zip_codes left join egrid_subregions on `egrid_subregions`.`abbreviation` = zip_codes.`egrid_subregion_abbreviation` where `egrid_subregions`.`abbreviation` is null
    # t.project('COUNT(*)').join(a_t, Arel::Nodes::OuterJoin).on(a_t[assoc.association_primary_key].eq(t[assoc.foreign_key])).where(a_t[assoc.klass.primary_key].eq(nil))
    def nonexistent_owners?(conditions)
      relation = table.includes(association.name).where(
        table.arel_table[association.foreign_key].not_eq(nil).and(      # not this query's job
        association.klass.arel_table[association.klass.primary_key].eq(nil))  # columns in the right table are set to NULL if they don't exist
      )
      if conditions.empty?
        relation.count > 0
      else
        relation.where(conditions).count > 0
      end
    end

    def association
      return @association.first if @association.is_a?(Array) # ruby needs an easy way to memoize things that might be false or nil
      @association = table.reflect_on_all_associations(:belongs_to).select do |assoc|
        assoc.foreign_key == name
      end
      if @association.many?
        raise ArgumentError, "More than one association on #{table.name} uses foreign key #{name.inspect}"
      end
      @association.first
    end
  end
end
