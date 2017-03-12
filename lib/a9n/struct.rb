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

    def merge(another_data)
      data.merge!(another_data)
    end

    def method_missing(name, *args)
      if data.key?(name)
        fetch(name)
      else
        fail NoSuchConfigurationVariableError.new(name)
      end
    end

    private

    attr_reader :data
  end
end
