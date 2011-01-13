module TableWarnings
  class Blank
    attr_reader :table
    attr_reader :column_name
    def initialize(table, column_name)
      @table = table
      @column_name = column_name
    end
    def warning
      if table.count(:conditions => { column_name => ''}) > 0 or table.count(:conditions => { column_name => nil}) > 0
        "There are blanks in the `#{column_name}` column."
      end
    end
  end
end
