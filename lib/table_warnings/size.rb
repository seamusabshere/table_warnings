module TableWarnings
  class Size
    attr_reader :table
    attr_reader :approximate_size
    attr_reader :conditions

    def initialize(table, approximate_size, options = {})
      @table = table
      @approximate_size = approximate_size
      @conditions = options[:conditions] || {}
    end
    
    def messages
      current_count = effective_count
      unless allowed_size.include? current_count
        if conditions.empty?
          "Row count is expected to be #{allowed_size.to_s}, but is #{current_count}"
        else
          "Row count with conditions #{conditions.inspect} is expected to be #{allowed_size.to_s}, but is #{current_count}"
        end
      end
    end

    private

    def effective_count
      if conditions.empty?
        table.count
      else
        table.where(conditions).count
      end
    end

    def allowed_size
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
      when ::Range
        approximate_size
      when Numeric
        approximate_size..approximate_size
      end
    end
  end
end
