require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
require 'active_support/all'
require 'active_record'
require 'mini_record'
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

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'table_warnings'
class Test::Unit::TestCase
end
