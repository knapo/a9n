module A9n
  class Scope
    ROOT_NAME = :configuration

    attr_reader :name

    def initialize(name)
      @name = name.to_sym
    end

    def root?
      name == ROOT_NAME
    end

    def env_key_name(key)
      (root? ? key : "#{name}_#{key}").upcase
    end

    def self.form_file_path(path)
      name = File.basename(path.to_s).split('.').first.to_sym
      self.new(name)
    end
  end
end
