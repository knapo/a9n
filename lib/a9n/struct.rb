module A9n
  class Struct
    extend Forwardable

    attr_reader :data

    def_delegators :data, :empty?, :keys, :key?, :fetch, :[], :[]=

    def initialize(data = {})
      @data = data
    end

    alias to_hash data
    alias to_h data

    def merge(another_data)
      data.merge!(another_data)
    end

    def method_missing(name, *_args)
      if data.key?(name)
        fetch(name)
      else
        raise NoSuchConfigurationVariableError.new, name
      end
    end

    def set(key, value)
      data[key.to_sym] = value
    end
  end
end
