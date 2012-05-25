module TableWarnings
  class Null < Exclusive
    def message(column)
      if column.null_count(conditions) > 0
        if conditions.empty?
          "There are NULLs in the #{column.name.inspect} column."
        else
          "There are NULLs with the conditions #{conditions.inspect} in the #{column.name.inspect} column."
        end
      end
    end
  end
end
