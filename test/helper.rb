require 'rubygems'
require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new

require 'active_record'
require 'active_record_inline_schema'
require 'data_miner'
# thanks authlogic!
ActiveRecord::Schema.verbose = false
begin
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
rescue ArgumentError
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
end

# require 'logger'
# logger = Logger.new $stdout
# logger.level = Logger::DEBUG
# ActiveRecord::Base.logger = logger

class ActiveRecord::Base
  class << self
    def force_create!(attrs)
      record = new
      record.send "#{primary_key}=", attrs[primary_key.to_sym]
      record.attributes = attrs.except(primary_key.to_sym)
      record.save!
      record
    end
  end
end

class MiniTest::Spec
  # start transaction
  before do
    # activerecord-3.2.3/lib/active_record/fixtures.rb
    @fixture_connections = ActiveRecord::Base.connection_handler.connection_pools.values.map(&:connection)
    @fixture_connections.each do |connection|
      connection.increment_open_transactions
      connection.transaction_joinable = false
      connection.begin_db_transaction
    end
  end

  # rollback
  after do
    @fixture_connections.each do |connection|
      if connection.open_transactions != 0
        connection.rollback_db_transaction
        connection.decrement_open_transactions
      end
    end
    @fixture_connections.clear
    ActiveRecord::Base.clear_active_connections!
  end

  def assert_warning(model, message)
    hits = model.table_warnings.select { |warning| warning =~ message }
    if hits.none?
      flunk "#{model.name} unexpectedly didn't have warning #{message.inspect}"
    elsif hits.many?
      raise ArgumentError, "#{model.name} had MULTIPLE warnings like #{message.inspect}: #{hits.inspect}"
    end
  end

  def assert_no_warning(model, message)
    if model.table_warnings.any? { |warning| warning =~ message }
      flunk "#{model.name} unexpectedly had warning #{message.inspect}"
    end
  end

  def assert_causes_warning(model, messages)
    messages = [messages].flatten
    messages.each do |message|
      assert_no_warning model, message
    end
    yield
    messages.each do |message|
      assert_warning model, message
    end
  end
end

require 'table_warnings'

class AutomobileMake < ActiveRecord::Base
  self.primary_key = "name"

  col :name
  col :fuel_efficiency, :type => :float

  warn_if_blanks_in :name
  warn_if_nulls_in :fuel_efficiency
  warn_unless_size_is :dozens
  warn_if do
    if exists? ['fuel_efficiency < ?', 0]
      "That's a strange looking fuel efficiency"
    end
  end

  data_miner do
    process :auto_upgrade!
    import "fixtures", :url => "file://#{File.expand_path('../support/automobile_makes.csv', __FILE__)}" do
      key :name
      store :fuel_efficiency
    end
  end
end

class AutomobileFuel < ActiveRecord::Base
  col :name
  col :code
  col :energy_content, :type => :float

  warn_if_any_blanks
  warn_unless_size_is 1..10

  data_miner do
    process :auto_upgrade!
    import "fixtures", :url => "file://#{File.expand_path('../support/automobile_fuels.csv', __FILE__)}" do
      key :name
      store :code
      store :energy_content
    end
  end
end

class AutomobileVariant < ActiveRecord::Base
  self.primary_key = "row_hash"

  belongs_to :make, :class_name => 'AutomobileMake'
  belongs_to :fuel, :class_name => 'AutomobileFuel', :foreign_key => :code
  belongs_to :alt_fuel, :class_name => 'AutomobileFuel', :foreign_key => :code

  col :row_hash
  col :year, :type => :integer
  col :make_id
  col :fuel_id
  col :fuel_efficiency_city, :type => :float
  col :fuel_efficiency_highway, :type => :float
  col :alt_fuel_id
  col :alt_fuel_efficiency_city, :type => :float
  col :alt_fuel_efficiency_highway, :type => :float
  col :carline_class
  col :carline_mfr

  warn_if_nulls_except(
    :carline_mfr,
    :alt_fuel_id
  )
  warn_if_nulls_in /alt_fuel_efficiency/, :conditions => {:alt_fuel_id => nil}
  warn_if_nulls_in :carline_class, :conditions => 'year < 1998'
  warn_unless_size_is 499
  warn_unless_size_is 118, :conditions => { :year => 1997 }
  warn_unless_size_is 127, :conditions => { :year => 1998 }
  warn_unless_size_is 112, :conditions => { :year => 1999 }

  warn_if_missing_parent

  data_miner do
    process :auto_upgrade!
    import "fixtures", :url => "file://#{File.expand_path('../support/automobile_variants.csv', __FILE__)}" do
      key :row_hash
      store :year
      store :make_id
      store :fuel_id
      store :fuel_efficiency_city
      store :fuel_efficiency_highway
      store :alt_fuel_id
      store :alt_fuel_efficiency_city
      store :alt_fuel_efficiency_highway
      store :carline_class
      store :carline_mfr
    end
  end
end

DataMiner.run

DataMiner.model_names.each do |model_name|
  if (warnings = model_name.constantize.table_warnings).any?
    puts "Warnings on #{model_name} fixtures:"
    puts warnings.join("\n")
  end
end
