module TableWarnings
  class Arbitrary
    attr_reader :table
    attr_reader :blk

    def initialize(table, blk)
      @table = table
      @blk = blk
    end
    
    def messages
      if messages = table.instance_eval(&blk)
        [messages].flatten.select { |message| message.present? }
      end
    end
  end
end
