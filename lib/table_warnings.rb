require 'active_record'

module TableWarnings
  autoload :Config, 'table_warnings/config'
  autoload :Warning, 'table_warnings/warning'

  def self.config #:nodoc: all
    Config.instance
  end

  # Get current warnings on the table.
  def table_warnings
    ::TableWarnings.config.warnings[self].map { |w| w.messages }.flatten.compact.sort
  end
  
  # Warn if there are blanks in a certain column.
  #
  # Blank includes both NULL and "" (empty string)
  def warn_if_blanks_in(column_name)
    warning = ::TableWarnings::Warning::Blank.new :table => self, :column_name => column_name
    ::TableWarnings.config.warnings[self].add warning
  end
  
  # Warn if there are blanks in ANY column.
  #
  # Blank includes both NULL and "" (empty string)
  def warn_if_any_blanks
    warning = ::TableWarnings::Warning::Blank.new :table => self
    ::TableWarnings.config.warnings[self].add warning
  end
  
  # Warn if the number of records falls out of an (approximate) range.
  #
  # Approximations: :few, :tens, :dozens, :hundreds, :thousands, :hundreds_of_thousands, :millions
  # Exact: pass a Range or a Numeric
  def warn_unless_size_is(approximate_size)
    warning = ::TableWarnings::Warning::Size.new :table => self, :approximate_size => approximate_size
    ::TableWarnings.config.warnings[self].add warning
  end
  
  # An arbitrary warning.
  def warn(&blk)
    warning = ::TableWarnings::Warning::Arbitrary.new :table => self, :blk => blk
    ::TableWarnings.config.warnings[self].add warning
  end
end

unless ::ActiveRecord::Base.method_defined? :table_warnings
  ::ActiveRecord::Base.extend ::TableWarnings
end
