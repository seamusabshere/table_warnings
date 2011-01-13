require 'helper'

class AutomobileMake < ActiveRecord::Base
  extend TableWarnings
  table_warnings do
    blank :name
    blank :fuel_efficiency
    size :hundreds
  end
end

class TestTableWarnings < Test::Unit::TestCase
  def setup
    # Too slow
    # AutomobileMake.run_data_miner!
    # Fake it - this actually happens with earth 0.3.11
    AutomobileMake.delete_all
    AutomobileMake.create! :name => '', :fuel_efficiency => nil, :fuel_efficiency_units => 'kilometres_per_litre'
    AutomobileMake.create! :name => 'Alfa Romeo', :fuel_efficiency => 10.4075, :fuel_efficiency_units => 'kilometres_per_litre'
  end

  def test_warn_for_blanks_in_automobile_make
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks in.*name.*column/ }
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks in.*fuel_efficiency.*column/ }
  end
  def test_warn_of_size_of_automobile_make
    assert AutomobileMake.table_warnings.one? { |w| w =~ /expected.*size/ }
  end
end
