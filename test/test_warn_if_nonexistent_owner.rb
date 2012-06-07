require 'helper'

class Person < ActiveRecord::Base
  col :llc_name
end
Person.auto_upgrade!

class PetRed < ActiveRecord::Base
  col :handler_id, :type => :integer
  belongs_to :handler, :class_name => 'Person'
  warn_if_nonexistent_owner :handler
end
PetRed.auto_upgrade!

class PetBlue < ActiveRecord::Base
  col :trainer_id
  belongs_to :trainer, :class_name => 'Person', :primary_key => :llc_name
  warn_if_nonexistent_owner :trainer
end
PetBlue.auto_upgrade!

class PetGreen < ActiveRecord::Base
  col :trainer_id
  belongs_to :trainer, :class_name => 'Person', :primary_key => :llc_name
  warn_if_nonexistent_owner :trainer, :allow_null => true
end
PetGreen.auto_upgrade!

describe TableWarnings do
  describe :warn_if_nonexistent_owner do
    before do
      Person.force_create! :llc_name => 'My Small Business, LLC'
    end
    it "takes a single belongs-to association name" do
      assert_causes_warning PetRed, /nonexistent.*handler/i do
        PetRed.force_create!
      end
    end
    it "checks the value of foreign keys not just their presence" do
      assert_causes_warning PetRed, /nonexistent.*handler/i do
        PetRed.force_create! :handler_id => 999999
      end
    end
    it "doesn't raise false warnings" do
      assert_does_not_cause_warning PetRed do
        PetRed.force_create! :handler_id => Person.first.id
      end
    end
    it "regards nulls as nonexistent even if the association primary key column contains nulls" do
      assert_causes_warning PetBlue, /nonexistent.*trainer/i do
        PetBlue.force_create!
      end
    end
    it "allows nulls if explicitly requested" do
      assert_does_not_cause_warning PetGreen do
        PetGreen.force_create!
      end
    end
  end
end
