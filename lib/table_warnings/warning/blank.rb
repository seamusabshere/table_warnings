module TableWarnings
  class Warning
    class Blank < Warning
      def column_name
        @column_name.to_s
      end
      
      def columns_hash
        if column_name.present?
          table.columns_hash.slice column_name
        else
          table.columns_hash
        end
      end
      
      def messages
        columns_hash.map do |_, c|
          if table.count(:conditions => { c.name => nil }) > 0 or (c.text? and table.count(:conditions => [ "TRIM(#{table.quoted_table_name}.#{c.name}) = ''"]) > 0)
            "There are blanks in the `#{c.name}` column."
          end
        end
      end
    end
  end
end
