module A9n
  class Hash
    class << self
      def deep_prepare(hash, scope)
        hash.inject({}) do |result, (key, value)|
          result[(key.to_sym rescue key)] = get_value(key, value, scope)
          result
        end
      end

      def merge(*items)
        return nil if items.compact.empty?
        items.compact.inject({}){|sum, item| sum.merge!(item)}
      end

      private

      def get_value(key, value, scope)
        if value.is_a?(::Hash)
          deep_prepare(value, scope)
        elsif value.is_a?(Symbol) && value == :env
          A9n.get_env_var(scope.env_key_name(key), true)
        else
          value
        end
      end
    end
  end
end
