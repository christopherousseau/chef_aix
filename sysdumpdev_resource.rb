  actions :primary, :secondary, :estimate, :list, :dumpstats
  default_action :list
  attr_accessor :exists
  
  attribute :set_default, :kind_of => [TrueClass, FalseClass], :default => false
  attribute :device, :kind_of => String :name_attribute => true
  attribute :directory, :kind_of => [String, NilClass]

