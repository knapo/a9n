module A9n
  class Hash
    class << self
      def deep_prepare(hash, scope)
        hash.inject({}) do |result, (key, value)|
          key_name = key.respond_to?(:to_sym) ? key.to_sym : key
          result[key_name] = get_value(key, value, scope)
          result
        end
      end

      def merge(*items)
        return nil if items.compact.empty?

        items.compact.inject({}) { |sum, item| sum.merge!(item) }
      end

      private

      def get_value(key, value, scope)
        if value.is_a?(::Hash)
          deep_prepare(value, scope).freeze
        elsif value.is_a?(Symbol) && value == :env
          A9n.env_var(scope.env_key_name(key), strict: A9n.strict?)
        else
          value.freeze
        end
      end
    end
  end
end
