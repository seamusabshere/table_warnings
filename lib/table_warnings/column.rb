module TableWarnings
  class Column
    attr_reader :table
    attr_reader :name
    
    def initialize(table, name)
      @table = table
      @name = name
    end

    def null_count(conditions)
      table.where(conditions).where(name => nil).count
    end

    def string?
      table.columns_hash[name].try(:type) == :string
    end

    def blank_count(conditions)
      table.where(conditions).where(["LENGTH(TRIM(#{table.quoted_table_name}.#{name})) = 0"]).count
    end
  end
end
