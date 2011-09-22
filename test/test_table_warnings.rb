require 'helper'

class AutomobileMake < ActiveRecord::Base
  col :name
  col :fuel_efficiency, :type => :float
  col :fuel_efficiency_units
    
  warn_if_blanks_in :name
  warn_if_blanks_in :fuel_efficiency
  warn_unless_size_is :hundreds
  warn do
    if exists? ['fuel_efficiency < ?', 0]
      "That's a strange looking fuel efficiency"
    end
  end
end

class AutomobileFuelType < ActiveRecord::Base
  col :name
  col :code
  col :fuel_efficiency, :type => :float
  col :fuel_efficiency_units

  warn_if_any_blanks
  warn_unless_size_is 1..6
end

AutomobileMake.auto_upgrade!
AutomobileFuelType.auto_upgrade!

class TestTableWarnings < Test::Unit::TestCase
  def setup
    AutomobileMake.delete_all
    AutomobileFuelType.delete_all
  end
  
  def test_001_warn_for_blanks_in_specific_columns
    AutomobileMake.create! :name => '       ', :fuel_efficiency => nil, :fuel_efficiency_units => 'kilometres_per_litre'
    AutomobileMake.create! :name => 'Alfa Romeo', :fuel_efficiency => 10.4075, :fuel_efficiency_units => 'kilometres_per_litre'
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks.*name.*column/ }
    assert AutomobileMake.table_warnings.one? { |w| w =~ /blanks.*fuel_efficiency.*column/ }
  end
  
  def test_002_warn_of_size
    assert AutomobileMake.table_warnings.one? { |w| w =~ /expected.*100\.\.1000/ }
    assert AutomobileFuelType.table_warnings.one? { |w| w =~ /expected.*1\.\.6/ }
  end

  def test_003_warn_for_blanks_in_any_column
    AutomobileFuelType.create! :name => 'gas'
    assert AutomobileFuelType.table_warnings.one? { |w| w =~ /blanks.*code.*column/ }
    assert AutomobileFuelType.table_warnings.many? { |w| w =~ /blanks.*fuel_efficiency.*column/ }
  end

  def test_004_dont_treat_0_as_blank
    AutomobileMake.create! :name => 'Acme', :fuel_efficiency => 0
    assert !AutomobileMake.table_warnings.any? { |w| w =~ /blanks.*fuel_efficiency.*column/ }
  end
  
  def test_005_warn_if_arbitrary_block
    AutomobileMake.create! :name => 'Acme', :fuel_efficiency => -5
    assert AutomobileMake.table_warnings.one? { |w| w =~ /strange looking fuel efficiency/ }
  end
end
