require 'ostruct'

module A9n
  class Struct < OpenStruct
    def empty?
      @table.empty?
    end

    def keys
      @table.keys
    end

    def fetch(name, default = nil)
      @table.fetch(name.to_sym, default)
    end

    def key?(key)
      to_h.key?(key)
    end

    def merge(key_value)
      key_value.each_pair do |key, value|
        self[key] = value
      end
    end

    def method_missing(name, *args)
      raise NoSuchConfigurationVariable.new(name)
    end
  end
end
