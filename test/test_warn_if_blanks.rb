require 'helper'

class PetDoh < ActiveRecord::Base
  col :gender
  warn_if_blanks :gender
end
PetDoh.auto_upgrade!

describe TableWarnings do
  describe :warn_if_nulls do
    it "takes a single column" do
      assert_causes_warning PetDoh, /blank.*gender/i do
        PetDoh.force_create!
      end
    end
  end
end
