require 'rubygems'
require 'bundler/setup'

if ::Bundler.definition.specs['debugger'].first
  require 'debugger'
elsif ::Bundler.definition.specs['ruby-debug'].first
  require 'ruby-debug'
end

require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new

require 'active_record'
require 'active_record_inline_schema'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

# require 'logger'
# logger = Logger.new $stdout
# logger.level = Logger::DEBUG
# ActiveRecord::Base.logger = logger

class ActiveRecord::Base
  class << self
    # ignores protected attrs
    def force_create!(attrs = {})
      record = new
      attrs.each do |k, v|
        record.send "#{k}=", v
      end
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

  def assert_warning(model, expected_warning)
    hits = model.table_warnings.select { |warning| warning =~ expected_warning }
    refute hits.none?, "#{model.name} unexpectedly lacked warning #{expected_warning.inspect}"
    refute hits.many?, "#{model.name} had MULTIPLE warnings like #{expected_warning.inspect}: #{hits.inspect}"
  end

  def refute_warning(model, specific_unexpected_warning = nil)
    raise if block_given?
    warnings = model.table_warnings
    if specific_unexpected_warning
      refute(warnings.any? { |warning| warning =~ specific_unexpected_warning }, "#{model.name} unexpectedly had warning #{specific_unexpected_warning.inspect}")
    else
      refute warnings.any?, "#{model.name} unexpectedly had some warnings (#{warnings.inspect})"
    end
  end

  def assert_causes_warning(model, expected_warnings)
    expected_warnings = [expected_warnings].flatten
    expected_warnings.each do |expected_warning|
      refute_warning model, expected_warning
    end
    warnings_before = model.table_warnings
    yield
    expected_warnings.each do |expected_warning|
      assert_warning model, expected_warning
    end
    unexpected_warnings = (model.table_warnings - warnings_before).reject do |warning|
      expected_warnings.any? { |expected_warning| warning =~ expected_warning }
    end
    refute unexpected_warnings.any?, "#{model.name} unexpectedly ALSO got warnings #{unexpected_warnings.inspect}"
  end

  def refute_causes_warning(model)
    refute_warning model
    yield
    refute_warning model
  end

end

require 'table_warnings'
