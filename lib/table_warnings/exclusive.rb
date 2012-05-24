module TableWarnings
  class Exclusive
    attr_reader :table
    attr_reader :scout
    attr_reader :conditions

    def initialize(table, matcher, options = {})
      @table = table
      @conditions = options[:conditions] || {}
      @scout = Scout.new matcher, options
    end

    def reserve(columns)
      columns.select do |column|
        scout.reserve? column
      end
    end

    def messages(columns)
      columns.select do |column|
        scout.match? column
      end.map do |column|
        message column
      end
    end
  end
end
