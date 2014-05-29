require "a9n/version"
require "a9n/struct"
require "a9n/ext/hash"
require "a9n/loader"
require "yaml"
require "erb"

module A9n
  class ConfigurationNotLoaded < StandardError; end
  class MissingConfigurationData < StandardError; end
  class MissingConfigurationVariables < StandardError; end
  class NoSuchConfigurationVariable < StandardError; end

  DEFAULT_SCOPE = :configuration
  DEFAULT_FILE = "#{DEFAULT_SCOPE}.yml"

  class << self
    def env
      @env ||= app_env || get_env_var("RAILS_ENV") || get_env_var("RACK_ENV") || get_env_var("APP_ENV")
    end

    def app_env
      app.env if app && app.respond_to?(:env)
    end

    def app
      @app ||= get_rails
    end

    def app=(app_instance)
      @app = app_instance
    end

    def root
      @root ||= app.root
    end

    def root=(path)
      @root = path.to_s.empty? ? nil : Pathname.new(path.to_s)
    end

    def get_rails
      defined?(Rails) ? Rails : nil
    end

    def get_env_var(name)
      ENV[name]
    end

    def fetch(*args)
      scope(DEFAULT_SCOPE).fetch(*args)
    end

    def scope(name)
      load unless instance_variable_defined?(var_name_for(name))
      instance_variable_get(var_name_for(name))
    end

    def var_name_for(file)
      :"@#{File.basename(file.to_s, '.*')}"
    end

    def default_files
      [root.join("#{DEFAULT_SCOPE}.yml").to_s] + Dir[root.join("config/a9n/*.yml")]
    end

    def load(*files)
      if files.empty?
        files = default_files
      else
        files = get_absolute_paths_for(files)
      end
      files.map do |file|
        instance_variable_set(var_name_for(file), A9n::Loader.new(file, env).get)
      end
    end

    def method_missing(name, *args)
      if scope(name).is_a?(A9n::Struct)
        scope(name)
      else
        scope(DEFAULT_SCOPE).send(name, *args)
      end
    end

    private

    def get_absolute_paths_for(files)
      files.map { |file| Pathname.new(file).absolute? ? file : self.root.join('config', file).to_s }
    end
  end
end
