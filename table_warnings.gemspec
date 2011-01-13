# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'table_warnings/version'

Gem::Specification.new do |s|
  s.name        = 'table_warnings'
  s.version     = TableWarnings::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Seamus Abshere']
  s.email       = ['seamus@abshere.net']
  s.homepage    = 'http://github.com/seamusabshere/table_warnings'
  s.summary     = %q{Validate an entire [ActiveRecord] table, checking for things like blank rows or total number of rows}
  s.description = %q{It's called validations to remind people of per-record validations, but it works on the table, and is meant to be used after a table is completely populated.}

  s.rubyforge_project = 'table_warnings'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_development_dependency 'fastercsv'
  s.add_development_dependency 'earth', '0.3.11'
  s.add_dependency 'activerecord' # for now
  s.add_dependency 'blockenspiel'
end
