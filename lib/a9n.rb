require "a9n/version"
require "a9n/struct"
require "a9n/core_ext/hash"
require "yaml"
require "erb"

module A9n
  class ConfigurationNotLoaded < StandardError; end
  class MissingConfigurationData < StandardError; end
  class MissingConfigurationVariables < StandardError; end
  class NoSuchConfigurationVariable < StandardError; end

  DEFAULT_FILE = 'configuration.yml'
  DEFAULT_SCOPE = :configuration

  class << self
    def env
      @env ||= local_app_env || get_env_var("RAILS_ENV") || get_env_var("RACK_ENV") || get_env_var("APP_ENV")
    end

    def local_app_env
      local_app.env if local_app && local_app.respond_to?(:env)
    end

    def local_app
      @local_app ||= get_rails
    end

    def local_app=(local_app)
      @local_app = local_app
    end

    def root
      @root ||= local_app.root
    end

    def root=(path)
      path = path.to_s
      @root = path.empty? ? nil : Pathname.new(path.to_s)
    end

    def scope(name)
      instance_variable_get(var_name_for(name)) || (name == DEFAULT_SCOPE && load.first)
    end

    def load(*files)
      files = [DEFAULT_FILE] if files.empty?
      files.map do |file|
        default_and_env_config = load_config(file)

        instance_variable_set(var_name_for(file), A9n::Struct.new(default_and_env_config))
      end
    end

    def load_config(file)
      env_example      = load_yml("config/#{file}.example", env)
      env_local        = load_yml("config/#{file}", env)
      default_example  = load_yml("config/#{file}.example", "defaults")
      default_local    = load_yml("config/#{file}", "defaults")

      if env_example.nil? && env_local.nil? && default_example.nil? && default_local.nil?
        raise MissingConfigurationData.new("Configuration data was not found in neither config/#{file}.example nor config/#{file}")
      end

      example = Hash.merge(default_example, env_example)
      local = Hash.merge( default_local,env_local)

      if !example.nil? && !local.nil?
        verify!(example, local)
      end

      local || example
    end

    def load_yml(file, env)
      path = File.join(self.root, file)
      return nil unless File.exists?(path)
      yml = YAML.load(ERB.new(File.read(path)).result)

      if yml[env].is_a?(Hash)
        return yml[env].deep_symbolize_keys
      else
        return nil
      end
    end

    # Fixes rspec issue
    def to_ary
      nil
    end

    def fetch(*args)
      scope(DEFAULT_SCOPE).fetch(*args)
    end

    def method_missing(name, *args)
      if scope(name).is_a?(A9n::Struct)
        scope(name)
      else
        scope(DEFAULT_SCOPE).send(name, *args)
      end
    end

    def get_rails
      defined?(Rails) ? Rails : nil
    end

    def get_env_var(name)
      ENV[name]
    end

    private

    def verify!(example, local)
      missing_keys = example.keys - local.keys
      if missing_keys.any?
        raise MissingConfigurationVariables.new("Following variables are missing in your configuration file: #{missing_keys.join(",")}")
      end
    end

    def var_name_for(file)
      :"@#{file.to_s.split('.').first}"
    end
  end
end
