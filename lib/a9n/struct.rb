require 'ostruct'

module A9n
  class Struct < OpenStruct

    def blank?
      to_h.none?
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

    # backward compatibility for ruby < 2.0
    def []=(key, value)
      modifiable[new_ostruct_member(key)] = value
    end

    def method_missing(name, *args)
      raise NoSuchConfigurationVariable.new(name)
    end
  end
end
