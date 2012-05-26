module TableWarnings
  class NonexistentOwner
    attr_reader :table
    attr_reader :belongs_to_association_name
    attr_reader :conditions

    def initialize(table, belongs_to_association_name, options)
      @table = table
      @belongs_to_association_name = belongs_to_association_name
      @allow_null_query = options[:allow_null]
      @conditions = options[:conditions] || {}
    end

    def messages
      if nonexistent? or (not allow_null? and nulls?)
        if conditions.empty?
          "Foreign keys are nil and/or refer to nonexistent values in #{belongs_to_association_name.inspect}"
        else
          "Foreign keys are nil and/or refer to nonexistent values in #{belongs_to_association_name.inspect} given #{conditions.inspect}"
        end
      end
    end

    private

    def allow_null?
      @allow_null_query
    end

    # select zip_codes.* from zip_codes left join egrid_subregions on `egrid_subregions`.`abbreviation` = zip_codes.`egrid_subregion_abbreviation` where `egrid_subregions`.`abbreviation` is null
    # t.project('COUNT(*)').join(a_t, Arel::Nodes::OuterJoin).on(a_t[assoc.association_primary_key].eq(t[assoc.foreign_key])).where(a_t[assoc.klass.primary_key].eq(nil))
    def nonexistent?
      assoc = table.reflect_on_association(belongs_to_association_name)
      relation = table.includes(assoc.name).where(
        table.arel_table[assoc.foreign_key].not_eq(nil).and(      # not this query's job
        assoc.klass.arel_table[assoc.klass.primary_key].eq(nil))  # columns in the right table are set to NULL if they don't exist
      )
      if conditions.empty?
        relation.count > 0
      else
        relation.where(conditions).count > 0
      end
    end

    def nulls?
      assoc = table.reflect_on_association(belongs_to_association_name)
      relation = table.where(assoc.foreign_key => nil)
      if conditions.empty?
        relation.count > 0
      else
        relation.where(conditions).count > 0
      end
    end
  end
end