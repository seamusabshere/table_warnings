require 'helper'

class PetOdin < ActiveRecord::Base
  warn_unless_size 0
end
PetOdin.auto_upgrade!

class PetDva < ActiveRecord::Base
  warn_unless_size 0..1
end
PetDva.auto_upgrade!

describe TableWarnings do
  describe :warn_unless_size do
    it "takes an exact integer" do
      assert_causes_warning PetOdin, /expected.*0/ do
        PetOdin.force_create!
      end
    end
    it "takes a range" do
      refute_warning PetDva
      
      refute_causes_warning PetDva do
        PetDva.force_create!
      end

      assert_causes_warning PetDva, /expected.*0..1/ do
        PetDva.force_create!
        PetDva.force_create!
      end
    end
  end
end