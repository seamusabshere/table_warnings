require 'helper'

describe TableWarnings do
  describe :warn_if_nulls_except do
    it "warns if nils in any columns except those listed" do
      assert_causes_warning AutomobileVariant, /null.*year/i do
        AutomobileVariant.force_create! :row_hash => 'bad', :year => nil
      end
    end
  end

  describe :warn_if_nulls_in do
    it "warns if nils in certain columns" do
      assert_causes_warning AutomobileMake, /null.*fuel_efficiency/i do
        AutomobileMake.force_create! :name => 'bad', :fuel_efficiency => nil
      end
    end
  end

  describe :warn_if_blanks_in do
    it "warns if blanks in certain columns" do
      assert_causes_warning AutomobileMake, /blank.*name/ do
        AutomobileMake.force_create! :name => '       '
      end
    end

    it "doesn't treat 0 as blank" do
      AutomobileMake.force_create! :name => 'Acme', :fuel_efficiency => 0
      assert_no_warning AutomobileMake, /blank.*fuel_efficiency/
    end
  end

  describe :warn_unless_size_is do
    it "warns unless size is as expected" do
      assert_causes_warning AutomobileMake, /expected.*10\.\.100/ do
        AutomobileMake.delete_all
      end  
      assert_causes_warning AutomobileFuel, /expected.*1\.\.10/ do
        AutomobileFuel.delete_all
      end
    end
  end

  describe :warn_if_any_blanks do
    it "warns if blanks in any column" do
      assert_causes_warning AutomobileFuel, [/blank.*energy_content/, /blank.*code/] do
        AutomobileFuel.force_create! :name => 'bad', :code => ' ', :energy_content => nil
      end  
    end
  end

  describe :warn_if do
    it "runs an arbitrary block to create warnings" do
      assert_causes_warning AutomobileMake, /strange looking fuel efficiency/ do
        AutomobileMake.force_create! :name => 'Acme', :fuel_efficiency => -5
      end
    end
  end
end
