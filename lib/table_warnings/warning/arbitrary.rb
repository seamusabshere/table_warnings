module TableWarnings
  class Warning
    class Arbitrary < Warning
      attr_reader :blk
      
      def messages
        if m = blk.call
          [m].flatten.select(&:present?)
        end
      end
    end
  end
end
