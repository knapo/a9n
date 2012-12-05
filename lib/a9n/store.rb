require 'ostruct'

module A9n
  class Store < OpenStruct
    def method_missing(name, *args)
      value = @table[name]
      if value.nil?
        raise NoSuchConfigurationVariable.new(name)
      else
        return value
      end
    end
  end
end