require 'ostruct'

module A9n
  class Struct < OpenStruct
    def keys
      @table.keys
    end

    def method_missing(name, *args)
      unless @table.key?(name.to_sym)
        raise NoSuchConfigurationVariable.new(name)
      end

      return @table[name.to_sym]
    end
  end
end