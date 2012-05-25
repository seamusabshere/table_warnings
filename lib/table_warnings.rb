require 'thread'

require 'active_support'
require 'active_support/version'
require 'active_support/core_ext' if ActiveSupport::VERSION::MAJOR >= 3
require 'active_record'

require 'table_warnings/registry'
require 'table_warnings/exclusive'
require 'table_warnings/blank'
require 'table_warnings/size'
require 'table_warnings/arbitrary'
require 'table_warnings/null'
require 'table_warnings/column'
require 'table_warnings/scout'
require 'table_warnings/nonexistent_owner'

module TableWarnings
  def TableWarnings.registry
    @registry || Thread.exclusive do
      @registry ||= Registry.new
    end
  end

  # used to resolve columns to warnings
  Disposition = Struct.new(:claims, :covers, :matches)

  # Get current warning messages on the table.
  def table_warnings
    messages = []

    TableWarnings.registry.nonexclusive(self).each do |warning|
      messages << warning.messages
    end

    exclusive = TableWarnings.registry.exclusive(self)
    pool = column_names.map do |column_name|
      TableWarnings::Column.new self, column_name
    end

    map = {}
    # pass 1 - claims and covers
    exclusive.each do |warning|
      disposition = Disposition.new
      disposition.claims = warning.claims pool
      disposition.covers = warning.covers pool
      map[warning] = disposition
      pool -= disposition.claims
    end
    if ENV['TABLE_WARNINGS_DEBUG'] == 'true'
      $stderr.puts "pass 1"
      map.each do |warning, disposition|
        $stderr.puts "  #{warning.scout.pattern} - claims=#{disposition.claims.map(&:name)} covers=#{disposition.covers.map(&:name)}"
      end
    end
    # pass 2 - allow regexp matching, but only if somebody else didn't cover it
    exclusive.each do |warning|
      disposition = map[warning]
      disposition.matches = warning.matches(pool).select do |match|
        map.except(warning).none? { |_, disposition| disposition.covers.include?(match) }
      end
      pool -= disposition.matches
    end
    if ENV['TABLE_WARNINGS_DEBUG'] == 'true'
      $stderr.puts "pass 2"
      map.each do |warning, disposition|
        $stderr.puts "  #{warning.scout.pattern} - claims=#{disposition.claims.map(&:name)} covers=#{disposition.covers.map(&:name)} matches=#{disposition.matches.map(&:name)}"
      end
    end
    if ENV['TABLE_WARNINGS_STRICT'] == 'true'
      $stderr.puts "uncovered columns"
      $stderr.puts pool.join("\n")
    end

    # now you can generate messages
    map.each do |warning, disposition|
      messages << warning.messages(disposition.claims+disposition.matches)
    end

    messages.flatten.compact
  end
  
  # Warn if there are blanks in a certain column.
  #
  # Blank includes both NULL and "" (empty string)
  def warn_if_blanks_in(*args)
    options = args.extract_options!
    args.flatten.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Blank.new(self, matcher, options)
    end
  end
  
  # Warn if there are NULLs in a certain column.
  def warn_if_nulls_in(*args)
    options = args.extract_options!
    args.flatten.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Null.new(self, matcher, options)
    end
  end

  # Warn if there are blanks in ANY column.
  def warn_if_any_blanks
    TableWarnings.registry.add_warning self, TableWarnings::Blank.new(self, /.*/)
  end

  # Warn if there are nulls in ANY column.
  def warn_if_any_nulls
    TableWarnings.registry.add_warning self, TableWarnings::Null.new(self, /.*/)
  end
  
  # Warn if the number of records falls out of an (approximate) range.
  #
  # Approximations: :few, :tens, :dozens, :hundreds, :thousands, :hundreds_of_thousands, :millions
  # Exact: pass a Range or a Numeric
  def warn_unless_size_is(approximate_size, options = {})
    TableWarnings.registry.add_warning self, TableWarnings::Size.new(self, approximate_size, options)
  end
  
  # An arbitrary warning.
  def warn_if(&blk)
    TableWarnings.registry.add_warning self, TableWarnings::Arbitrary.new(self, blk)
  end

  def warn_if_nulls_except(*args)
    options = args.extract_options!
    args.flatten.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Null.new(self, matcher, options.merge(:negative => true))
    end
  end

  def warn_if_blanks_except(*args)
    options = args.extract_options!
    args.flatten.each do |matcher|
      TableWarnings.registry.add_warning self, TableWarnings::Blank.new(self, matcher, options.merge(:negative => true))
    end
  end

  def warn_if_nonexistent_owner(*args)
    options = args.extract_options!
    args.flatten.each do |belongs_to_association_name|
      TableWarnings.registry.add_warning self, TableWarnings::NonexistentOwner.new(self, belongs_to_association_name, options)
    end
  end


end

unless ActiveRecord::Base.method_defined? :table_warnings
  ActiveRecord::Base.extend TableWarnings
end
