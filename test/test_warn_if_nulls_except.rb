require 'helper'

class PetA < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  warn_if_nulls_except :birthday
end
PetA.auto_upgrade!

class PetB < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  warn_if_nulls_except :birthday, :gender
end
PetB.auto_upgrade!

class PetC < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  warn_if_nulls_except /irthda/
end
PetC.auto_upgrade!

class PetD < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  warn_if_nulls_except /irthda/, /ende/
end
PetD.auto_upgrade!

class PetE < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :certified, :type => :boolean
  warn_if_nulls_except :birthday, :conditions => { :certified => true }
end
PetE.auto_upgrade!

class PetF < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :sire
  col :certified, :type => :boolean
  warn_if_nulls_except :birthday, :gender, :conditions => { :certified => true }
end
PetF.auto_upgrade!

class PetG < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :certified, :type => :boolean
  warn_if_nulls_except /irthda/, :conditions => { :certified => true }
end
PetG.auto_upgrade!

class PetH < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :sire
  col :certified, :type => :boolean
  warn_if_nulls_except /irthda/, /ende/, :conditions => { :certified => true }
end
PetH.auto_upgrade!

describe TableWarnings do
  describe :warn_if_nulls_except do
    it "takes a single column" do
      assert_causes_warning PetA, /null.*gender/i do
        PetA.force_create!
      end
    end
    it "takes multiple columns" do
      refute_causes_warning PetB do
        PetB.force_create!
      end
    end
    it "takes a single regexp" do
      assert_causes_warning PetC, /null.*gender/i do
        PetC.force_create!
      end
    end
    it "takes multiple regexps" do
      refute_causes_warning PetD do
        PetD.force_create!
      end
    end
    it "takes a single column and a condition" do
      refute_causes_warning PetE do
        PetE.force_create!
      end
      assert_causes_warning PetE, /null.*gender/i do
        PetE.force_create! :certified => true
      end
    end
    it "takes multiple columns and a condition" do
      refute_causes_warning PetF do
        PetF.force_create!
      end
      assert_causes_warning PetF, /null.*sire/i do
        PetF.force_create! :certified => true
      end
    end
    it "takes a single regexp and a condition" do
      refute_causes_warning PetG do
        PetG.force_create!
      end
      assert_causes_warning PetG, /null.*gender/i do
        PetG.force_create! :certified => true
      end
    end
    it "takes multiple regexps and a condition" do
      refute_causes_warning PetH do
        PetH.force_create!
      end
      assert_causes_warning PetH, /null.*sire/i do
        PetH.force_create! :certified => true
      end
    end
  end
end
