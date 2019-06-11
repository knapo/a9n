module A9n
  class Struct
    extend Forwardable

    def_delegators :data, :empty?, :keys, :key?, :fetch, :[], :[]=

    def initialize(data = {})
      @data = data
    end

    def to_hash
      data
    end

    alias to_h to_hash

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

    private

    attr_reader :data
  end
end
