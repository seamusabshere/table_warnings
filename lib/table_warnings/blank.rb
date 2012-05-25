module TableWarnings
  class Blank < Exclusive
    def message(column)
      if column.null_count(conditions) > 0 or (column.string? and column.blank_count(conditions) > 0)
        if conditions.empty?
          "There are blanks in the #{column.name.inspect} column."
        else
          "There are blanks with the condition #{conditions.inspect} in the #{column.name.inspect} column."
        end
      end
    end
  end
end
