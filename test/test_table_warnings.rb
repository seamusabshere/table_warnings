require 'helper'

class AutomobileMake < ActiveRecord::Base
  warn_if_blanks_in :name
  warn_if_blanks_in :fuel_efficiency
  warn_unless_size_is :hundreds
end

class AutomobileFuelType < ActiveRecord::Base
  warn_unless_size_is :few
end

AutomobileMake.create! :name => '', :fuel_efficiency => nil, :fuel_efficiency_units => 'kilometres_per_litre'
AutomobileMake.create! :name => 'Alfa Romeo', :fuel_efficiency => 10.4075, :fuel_efficiency_units => 'kilometres_per_litre'

AutomobileFuelType.create! :name => 'gas'
AutomobileFuelType.create! :name => 'diesel'

class TestTableWarnings < Test::Unit::TestCase
  def test_warn_for_blanks_in_automobile_make
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks in.*name.*column/ }
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks in.*fuel_efficiency.*column/ }
  end
  def test_warn_of_size_of_automobile_make
    assert AutomobileMake.table_warnings.one? { |w| w =~ /expected.*size/ }
  end
  def test_dont_warn_of_size_of_automobile_fuel_type
    assert AutomobileFuelType.table_warnings.empty?
  end
  def test_table_warning_hooks_are_unique_to_subclasses
    assert(AutomobileMake._table_warnings_hook != AutomobileFuelType._table_warnings_hook)
    assert(ActiveRecord::Base._table_warnings_hook != AutomobileMake._table_warnings_hook)
    assert(AutomobileFuelType._table_warnings_hook != ActiveRecord::Base._table_warnings_hook)
  end
end
