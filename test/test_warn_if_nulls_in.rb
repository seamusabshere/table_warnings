require 'helper'

class Pet1 < ActiveRecord::Base
  col :birthday, :type => :datetime
  warn_if_nulls_in :birthday
end
Pet1.auto_upgrade!

class Pet2 < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  warn_if_nulls_in :birthday, :gender
end
Pet2.auto_upgrade!

class Pet3 < ActiveRecord::Base
  col :birthday, :type => :datetime
  warn_if_nulls_in /irthda/
end
Pet3.auto_upgrade!

class Pet4 < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  warn_if_nulls_in /irthda/, /ende/
end
Pet4.auto_upgrade!

class Pet5 < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :certified, :type => :boolean
  warn_if_nulls_in :birthday, :conditions => { :certified => true }
end
Pet5.auto_upgrade!

class Pet6 < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :certified, :type => :boolean
  warn_if_nulls_in :birthday, :gender, :conditions => { :certified => true }
end
Pet6.auto_upgrade!

class Pet7 < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :certified, :type => :boolean
  warn_if_nulls_in /irthda/, :conditions => { :certified => true }
end
Pet7.auto_upgrade!

class Pet8 < ActiveRecord::Base
  col :birthday, :type => :datetime
  col :gender
  col :certified, :type => :boolean
  warn_if_nulls_in /irthda/, /ende/, :conditions => { :certified => true }
end
Pet8.auto_upgrade!

describe TableWarnings do
  describe :warn_if_nulls_in do
    it "takes a single column" do
      assert_causes_warning Pet1, /null.*birthday/i do
        Pet1.force_create!
      end
    end
    it "takes multiple columns" do
      assert_causes_warning Pet2, [/null.*birthday/i, /null.*gender/i] do
        Pet2.force_create!
      end
    end
    it "takes a single regexp" do
      assert_causes_warning Pet3, /null.*birthday/i do
        Pet3.force_create!
      end
    end
    it "takes multiple regexps" do
      assert_causes_warning Pet4, [/null.*birthday/i, /null.*gender/i] do
        Pet4.force_create!
      end
    end
    it "takes a single column and a condition" do
      assert_does_not_cause_warning Pet5 do
        Pet5.force_create!
      end
      assert_causes_warning Pet5, /null.*birthday/i do
        Pet5.force_create! :certified => true
      end
    end
    it "takes multiple columns and a condition" do
      assert_does_not_cause_warning Pet6 do
        Pet6.force_create!
      end
      assert_causes_warning Pet6, [/null.*birthday/i, /null.*gender/i] do
        Pet6.force_create! :certified => true
      end
    end
    it "takes a single regexp and a condition" do
      assert_does_not_cause_warning Pet7 do
        Pet7.force_create!
      end
      assert_causes_warning Pet7, /null.*birthday/i do
        Pet7.force_create! :certified => true
      end
    end
    it "takes multiple regexps and a condition" do
      assert_does_not_cause_warning Pet8 do
        Pet8.force_create!
      end
      assert_causes_warning Pet8, [/null.*birthday/i, /null.*gender/i] do
        Pet8.force_create! :certified => true
      end
    end
  end
end
