# Based on https://github.com/rails/rails/blob/master/activesupport/lib/active_support/string_inquirer.rb
module A9n
  class StringInquirer < String
    private

    def respond_to_missing?(method_name, include_private = false)
      (method_name[-1] == '?') || super
    end

    def method_missing(method_name, *arguments)
      if method_name[-1] == '?'
        self == method_name[0..-2]
      else
        super
      end
    end
  end
end
