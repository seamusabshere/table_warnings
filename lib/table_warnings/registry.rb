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

    def warnings_for(table)
      k = table.to_s
      if warnings.has_key?(k)
        warnings[k].dup
      else
        []
      end
    end

    def exclusive(table)
      warnings_for(table).select do |warning|
        warning.respond_to? :exclusives
      end
    end

    def nonexclusive(table)
      warnings_for(table).reject do |warning|
        warning.respond_to? :exclusives
      end
    end
  end
end
