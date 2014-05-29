module A9n
  class HashExt
    class << self
      # Hash#deep_symbolize_keys
      # based on
      # https://github.com/svenfuchs/i18n/blob/master/lib/i18n/core_ext/hash.rb
      def deep_symbolize_keys(hash)
        hash.inject({}) { |result, (key, value)|
          value = deep_symbolize_keys(value) if value.is_a?(::Hash)
          result[(key.to_sym rescue key) || key] = value
          result
        }
      end

      def merge(*items)
        return nil if items.compact.empty?
        items.compact.inject({}){|sum, item| sum.merge!(item)}
      end
    end
  end
end
