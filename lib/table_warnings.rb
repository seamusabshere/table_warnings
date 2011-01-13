require 'active_record'
require 'table_warnings/hook'
require 'table_warnings/signs/blank'
require 'table_warnings/signs/size'

module TableWarnings
  # Used to define the warning signs and also get back the warnings.
  #
  #     class AutomobileMake < ActiveRecord::Base
  #       extend TableWarnings
  #       table_warnings do
  #         blank :name
  #         blank :fuel_efficiency
  #         size :hundreds
  #       end
  #     end
  #
  # ...and to get them back...
  #
  #     ?> AutomobileMake.table_warnings
  #     => [ "Table is not of expected size" ]
  def table_warnings(&blk)
    @@table_warnings_hook ||= ::TableWarnings::Hook.new self
    if block_given?
      @@table_warnings_hook.define_signs &blk
    else
      @@table_warnings_hook.return_warnings
    end
  end
end
