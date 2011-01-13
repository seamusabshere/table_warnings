require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
require 'active_support/all'
require 'active_record'
# thanks authlogic!
ActiveRecord::Schema.verbose = false
begin
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
rescue ArgumentError
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
end
require 'earth'
Earth.init :automobile, :apply_schemas => true
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'table_warnings'
class Test::Unit::TestCase
end
