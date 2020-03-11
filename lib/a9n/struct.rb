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

    def find(key)
      if key && data.key?(key.to_sym)
        fetch(key.to_sym)
      else
        raise KeyNotFoundError.new, "Could not find #{key} in #{data.keys.inspect}"
      end
    end

    def method_missing(key, *_args)
      find(key)
    end

    def set(key, value)
      data[key.to_sym] = value
    end
  end
end
