class Hash
  # Hash#deep_symbolize_keys 
  # based on
  # https://github.com/svenfuchs/i18n/blob/master/lib/i18n/core_ext/hash.rb
  def deep_symbolize_keys
    inject({}) { |result, (key, value)|
      value = value.deep_symbolize_keys if value.is_a?(self.class)
      result[(key.to_sym rescue key) || key] = value
      result
    }
  end unless self.method_defined?(:deep_symbolize_keys)
end