module TableWarnings
  class Warning
    autoload :Blank, 'table_warnings/warning/blank'
    autoload :Size, 'table_warnings/warning/size'
    autoload :Arbitrary, 'table_warnings/warning/arbitrary'
    
    attr_reader :table
    
    def initialize(options = {})
      options.each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end
    
    def to_hash
      instance_variables.sort.inject({}) do |memo, ivar_name|
        memo[ivar_name.to_s.sub('@', '')] = instance_variable_get ivar_name
        memo
      end
    end
    
    def hash
      to_hash.hash
    end
    
    def eql?(other)
      other.is_a?(Warning) and self.to_hash == other.to_hash
    end
  end
end
