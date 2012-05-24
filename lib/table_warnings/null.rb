module TableWarnings
  class Null < Exclusive
    def message(column)
      if column.null_count(conditions) > 0
        "There are NULLs in the #{column.name.inspect} column."
      end
    end
  end
end
