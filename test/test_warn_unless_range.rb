require 'helper'

class PetUno < ActiveRecord::Base
  col :age, :type => :integer
  # sad!
  warn_unless_range :age, :min => 0, :max => 20
end
PetUno.auto_upgrade!

describe TableWarnings do
  describe :warn_unless_range do
    it "takes a single column and range" do
      assert_causes_warning PetUno, /range.*age/i do
        PetUno.force_create! :age => 100
      end
    end
  end
end
