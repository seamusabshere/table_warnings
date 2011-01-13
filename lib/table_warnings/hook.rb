module TableWarnings
  class Hook
    attr_reader :table
    def initialize(table)
      @table = table
    end
    def current_warnings
      signs.map(&:warning).compact
    end
    def warn_of(sign)
      signs << sign
    end
    def signs
      @signs ||= []
    end
  end
end
