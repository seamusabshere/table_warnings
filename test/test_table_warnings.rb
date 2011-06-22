require 'helper'

class AutomobileMake < ActiveRecord::Base
  warn_if_blanks_in :name
  warn_if_blanks_in :fuel_efficiency
  warn_unless_size_is :hundreds
  warn_unless_size_is 100..1000
end

class AutomobileFuelType < ActiveRecord::Base
  warn_if_any_blanks
  warn_unless_size_is :few
  warn_unless_size_is 1..6
end

class TestTableWarnings < Test::Unit::TestCase
  def setup
    AutomobileMake.delete_all
    AutomobileFuelType.delete_all
  end
  
  def test_001_warn_for_blanks_in_specific_columns
    AutomobileMake.create! :name => '       ', :fuel_efficiency => nil, :fuel_efficiency_units => 'kilometres_per_litre'
    AutomobileMake.create! :name => 'Alfa Romeo', :fuel_efficiency => 10.4075, :fuel_efficiency_units => 'kilometres_per_litre'
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks in.*name.*column/ }
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks in.*fuel_efficiency.*column/ }
  end
  
  def test_002_warn_of_size
    assert_equal 0, AutomobileMake.count
    assert AutomobileMake.table_warnings.many? { |w| w =~ /expected.*size/ }
  end

  def test_003_warn_for_blanks_in_any_column
    AutomobileFuelType.create! :name => 'gas'
    assert AutomobileFuelType.table_warnings.one? { |w| w =~ /blanks in.*code.*column/ }
  end

  def test_004_dont_treat_0_as_blank
    AutomobileMake.create! :name => 'Acme', :fuel_efficiency => 0
    assert !AutomobileMake.table_warnings.any? { |w| w =~ /blanks in.*fuel_efficiency.*column/ }
  end
end
