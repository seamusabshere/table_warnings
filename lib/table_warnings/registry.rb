module TableWarnings
  class Registry
    attr_reader :warnings

    def initialize
      @warnings = {}
      @warnings_mutex = Mutex.new
    end

    def add_warning(table, warning)
      @warnings_mutex.synchronize do
        warnings[table.to_s] ||= []
        warnings[table.to_s] << warning
      end
    end

    def exclusive(table)
      (warnings[table.to_s] || []).select do |warning|
        warning.respond_to? :reserve
      end
    end

    def nonexclusive(table)
      (warnings[table.to_s] || []).reject do |warning|
        warning.respond_to? :reserve
      end
    end
  end
end
