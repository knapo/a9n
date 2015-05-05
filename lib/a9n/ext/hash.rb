module A9n
  class HashExt
    class << self
      def deep_prepare(hash)
        hash.inject({}) do |result, (key, value)|
          result[(key.to_sym rescue key)] = get_value(key, value)
          result
        end
      end

      def merge(*items)
        return nil if items.compact.empty?
        items.compact.inject({}){|sum, item| sum.merge!(item)}
      end

      private

      def get_value(key, value)
        if value.is_a?(::Hash)
          deep_prepare(value)
        elsif value.is_a?(Symbol) && value == :env
          ENV[key.to_s.upcase]
        else
          value
        end
      end
    end
  end
end
