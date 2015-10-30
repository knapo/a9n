require 'ostruct'

module A9n
  class Struct < OpenStruct
    extend Forwardable

    def_delegators :@table, :empty?, :keys, :key?, :fetch

    def merge(key_value)
      key_value.each_pair do |key, value|
        self[key] = value
      end
    end

    def method_missing(name, *args)
      raise NoSuchConfigurationVariableError.new(name)
    end
  end
end
