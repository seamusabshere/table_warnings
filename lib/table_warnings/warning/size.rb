module TableWarnings
  class Warning
    class Size < Warning
      attr_reader :approximate_size
      
      def allowed_range
        case approximate_size
        when :few
          1..10
        when :dozens, :tens
          10..100
        when :hundreds
          100..1_000
        when :thousands
          1_000..99_000
        when :hundreds_of_thousands
          100_000..1_000_000
        when :millions
          1_000_000..1_000_000_000
        when Range
          approximate_size
        when Numeric
          approximate_size..approximate_size
        end
      end

      def messages
        unless allowed_range.include? table.count
          "Table is not of expected size (expected: #{allowed_range.to_s}, actual: #{table.count})"
        end
      end
    end
  end
end
