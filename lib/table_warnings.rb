require 'thread'

require 'active_support'
require 'active_support/version'
require 'active_support/core_ext' if ActiveSupport::VERSION::MAJOR >= 3
require 'active_record'

require 'table_warnings/registry'
require 'table_warnings/exclusive'
require 'table_warnings/blank'
require 'table_warnings/size'
require 'table_warnings/arbitrary'
require 'table_warnings/null'
require 'table_warnings/column'
require 'table_warnings/scout'

module TableWarnings
  def TableWarnings.registry
    @registry || Thread.exclusive do
      @registry ||= Registry.new
    end
  end

  # Get current warning messages on the table.
  # warnings.map { |warning| warning.messages }.flatten.compact.sort
  def table_warnings
    messages = []
    TableWarnings.registry.nonexclusive(self).each do |warning|
      messages << warning.messages
    end
    columns = column_names.map do |column_name|
      TableWarnings::Column.new self, column_name
    end
    TableWarnings.registry.exclusive(self).each do |warning|
      reserved = warning.reserve(columns)
      messages << warning.messages(columns)
      columns -= reserved
    end
    messages.flatten.compact
  end
  
  # Warn if there are blanks in a certain column.
  #
  # Blank includes both NULL and "" (empty string)
  def warn_if_blanks_in(*args)
    options = args.extract_options!
    matchers = args.flatten
    matchers.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Blank.new(self, matcher, options)
    end
  end
  
  # Warn if there are NULLs in a certain column.
  def warn_if_nulls_in(*args)
    options = args.extract_options!
    matchers = args.flatten
    matchers.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Null.new(self, matcher, options)
    end
  end

  # Warn if there are blanks in ANY column.
  def warn_if_any_blanks
    TableWarnings.registry.add_warning self, TableWarnings::Blank.new(self, /.*/)
  end

  # Warn if there are nulls in ANY column.
  def warn_if_any_nulls
    TableWarnings.registry.add_warning self, TableWarnings::Null.new(self, /.*/)
  end
  
  # Warn if the number of records falls out of an (approximate) range.
  #
  # Approximations: :few, :tens, :dozens, :hundreds, :thousands, :hundreds_of_thousands, :millions
  # Exact: pass a Range or a Numeric
  def warn_unless_size_is(approximate_size, options = {})
    TableWarnings.registry.add_warning self, TableWarnings::Size.new(self, approximate_size, options)
  end
  
  # An arbitrary warning.
  def warn_if(&blk)
    TableWarnings.registry.add_warning self, TableWarnings::Arbitrary.new(self, blk)
  end

  def warn_if_nulls_except(*args)
    options = args.extract_options!
    matchers = args.flatten
    matchers.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Null.new(self, matcher, options.merge(:negative => true))
    end
  end

  def warn_if_blanks_except(*args)
    options = args.extract_options!
    matchers = args.flatten
    matchers.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Blank.new(self, matcher, options.merge(:negative => true))
    end
  end

  def warn_if_missing_parent
    #wip
  end


end

unless ActiveRecord::Base.method_defined? :table_warnings
  ActiveRecord::Base.extend TableWarnings
end
