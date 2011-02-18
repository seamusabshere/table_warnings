module TableWarnings
  class Warning
    class Blank < Warning
      attr_reader :column_name
      
      def effective_column_names
        if column_name
          [column_name]
        else
          table.column_names
        end
      end
      
      def messages
        effective_column_names.map do |c|
          if table.count(:conditions => { c => ''}) > 0 or table.count(:conditions => { c => nil }) > 0
            "There are blanks in the `#{c}` column."
          end
        end
      end
    end
  end
end
