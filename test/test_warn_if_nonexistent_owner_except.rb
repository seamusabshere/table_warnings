require 'helper'

class Gente < ActiveRecord::Base
  col :llc_name
end
Gente.auto_upgrade!

class PetRojo < ActiveRecord::Base
  col :handler_id, :type => :integer
  col :trainer_id
  belongs_to :handler, :class_name => 'Gente'
  belongs_to :trainer, :class_name => 'Gente', :primary_key => :llc_name
  warn_if_nonexistent_owner_except :handler
end
PetRojo.auto_upgrade!

class PetAzul < ActiveRecord::Base
  col :handler_id, :type => :integer
  col :trainer_id
  belongs_to :handler, :class_name => 'Gente'
  belongs_to :trainer, :class_name => 'Gente', :primary_key => :llc_name
  warn_if_nonexistent_owner_except :trainer
end
PetAzul.auto_upgrade!

class PetVerde < ActiveRecord::Base
  col :handler_id, :type => :integer
  col :trainer_id
  belongs_to :handler, :class_name => 'Gente'
  belongs_to :trainer, :class_name => 'Gente', :primary_key => :llc_name
  warn_if_nonexistent_owner_except :trainer, :allow_null => true
end
PetVerde.auto_upgrade!

describe TableWarnings do
  describe :warn_if_nonexistent_owner_except do
    before do
      Gente.force_create! :llc_name => 'My Small Business, LLC'
    end
    it "takes a single belongs-to association name" do
      assert_causes_warning PetRojo, /trainer.*do not correspond/i do
        PetRojo.force_create!
      end
    end
    it "checks the value of foreign keys not just their presence" do
      assert_causes_warning PetRojo, /trainer.*do not correspond/i do
        PetRojo.force_create! :trainer_id => 999999
      end
    end
    it "doesn't raise false warnings" do
      assert_does_not_cause_warning PetRojo do
        PetRojo.force_create! :trainer_id => Gente.first.llc_name
      end
    end
    it "regards nulls as nonexistent even if the association primary key column contains nulls" do
      assert_causes_warning PetAzul, /handler.*do not correspond/i do
        PetAzul.force_create!
      end
    end
    it "allows nulls if explicitly requested" do
      assert_does_not_cause_warning PetVerde do
        PetVerde.force_create!
      end
    end

  end
end
