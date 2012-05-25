require 'helper'

class PetAlpha < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :sire
  warn_if_nulls_in :birthday
  warn_if_nulls_except :gender
end
PetAlpha.auto_upgrade!

class PetBeta < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :sire
  warn_if_nulls_in :birthday
  warn_if_nulls_except /ende/
end
PetBeta.auto_upgrade!

class PetGamma < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :sire
  col :certified, :type => :boolean
  warn_if_nulls_in /irthd/, :conditions => { :certified => true }
  warn_if_nulls_except /ende/
end
PetGamma.auto_upgrade!

class PetDelta < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :sire
  col :certified, :type => :boolean
  warn_if_nulls_in /irthd/, :conditions => { :certified => true }
  warn_if_nulls_except /ende/, :conditions => { :certified => true }
end
PetDelta.auto_upgrade!

describe TableWarnings do
  describe "combinations of positive ('in') and negative ('except') rules" do
    it "combines a positive column and a negative column" do
      assert_causes_warning PetAlpha, [/null.*birthday/i, /null.*sire/i] do
        PetAlpha.force_create!
      end
    end
    it "combines a positive column and a negative regexp" do
      assert_causes_warning PetBeta, [/null.*birthday/i, /null.*sire/i] do
        PetBeta.force_create!
      end
    end
    it "combines a positive regexp with conditions and a negative regexp" do
      assert_causes_warning PetGamma, [/null.*sire/i, /null.*certified/i] do
        PetGamma.force_create!
      end
      PetGamma.delete_all # !
      assert_causes_warning PetGamma, [/null.*sire/i, /null.*birthday/i] do
        PetGamma.force_create! :certified => true
      end
    end
    it "combines a positive regexp with conditions and a negative regexp with conditions" do
      assert_does_not_cause_warning PetDelta do
        PetDelta.force_create!
      end
      PetDelta.delete_all # !
      assert_causes_warning PetDelta, [/null.*sire/i, /null.*birthday/i] do
        PetDelta.force_create! :certified => true
      end
    end
  end
end

=begin
warn_if_nulls_except(
  :alt_fuel_code,
  :carline_mfr_code,
  :vi_mfr_code,
  :carline_code,
  :carline_class_code,
  :carline_class_name,
)
warn_if_nulls_in /alt_fuel_efficiency/, :conditions => 'alt_fuel_code IS NOT NULL'
warn_if_nulls_in :carline_class, :conditions => 'year < 1998'
=end
