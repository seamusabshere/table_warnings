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

    def claims(columns)
      columns.select { |column| scout.claim? column }
    end

    def matches(columns)
      columns.select { |column| scout.match? column }
    end

    def covers(columns)
      columns.select { |column| scout.cover? column }
    end

    def messages(columns)
      columns.map do |column|
        message column
      end
    end
  end
end
