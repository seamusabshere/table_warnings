require 'blockenspiel'

module TableWarnings
  class Hook
    attr_reader :table
    def initialize(table)
      @table = table
    end
    def define_signs(&blk)
      ::Blockenspiel.invoke blk, dsl
    end
    def return_warnings
      signs.map(&:warning).compact
    end
    def watch_for(sign)
      signs << sign
    end
    def signs
      @signs ||= []
    end
    def dsl
      @dsl ||= DSL.new self
    end
    class DSL
      include ::Blockenspiel::DSL
      attr_reader :hook
      def initialize(hook)
        @hook = hook
      end
      def blank(column_name)
        hook.watch_for Blank.new(hook.table, column_name)
      end
      def size(approximate_size)
        hook.watch_for Size.new(hook.table, approximate_size)
      end
    end
  end
end
