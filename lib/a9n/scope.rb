module A9n
  class Scope
    ROOT_NAMES = [:configuration, :a9n].freeze

    attr_reader :name

    def initialize(name)
      @name = name.to_sym
    end

    def root?
      ROOT_NAMES.include?(name)
    end

    def env_key_name(key)
      (root? ? key : "#{name}_#{key}").upcase
    end

    def self.form_file_path(path)
      new(File.basename(path.to_s).split('.').first.to_sym)
    end
  end
end
