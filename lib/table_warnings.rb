require 'active_record'
require 'table_warnings/hook'
require 'table_warnings/signs/blank'
require 'table_warnings/signs/size'

module TableWarnings
  # Get current warnings on the table.
  def table_warnings
    _table_warnings_hook.current_warnings
  end
  # Warn if there are blanks in a certain column.
  #
  # Blank includes both NULL and "" (empty string)
  def warn_if_blanks_in(column_name)
    _table_warnings_hook.warn_of ::TableWarnings::Blank.new(self, column_name)
  end
  # Warn if the number of records falls out of an (approximate) range.
  #
  # Approximations: :few, :tens, :dozens, :hundreds, :thousands, :hundreds_of_thousands, :millions
  # Exact: pass a Range or a Numeric
  def warn_unless_size_is(approximate_size)
    _table_warnings_hook.warn_of ::TableWarnings::Size.new(self, approximate_size)
  end
  def _table_warnings_hook # :nodoc:
    @table_warnings_hook ||= ::TableWarnings::Hook.new self
  end
end

::ActiveRecord::Base.extend ::TableWarnings
