require 'singleton'
require 'set'
module TableWarnings
  class Config
    include ::Singleton

    def warnings
      @warnings ||= ::Hash.new { |hash, key| hash[key] = ::Set.new }
    end
  end
end
