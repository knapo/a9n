require 'a9n/version'
require 'a9n/store'

module A9n
  class ConfigurationNotLoaded < StandardError; end
  class MissingConfigurationFile < StandardError; end
  class MissingConfigurationVariables < StandardError; end
  class NoSuchConfigurationVariable < StandardError; end
  
  class << self

    def cfg
      @@configuration
    rescue NameError
      raise ConfigurationNotLoaded.new("Configuration does not seem to be loaded. Plase call A9n.load.")
    end

    def env
      @@env ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ENV['APP_ENV']
    end

    def local_app
      @@local_app ||= Rails
    end

    def local_app=(local_app)
      @@local_app = local_app
    end

    def load
      base  = load_yml('config/configuration.yml.example')
      local = load_yml('config/configuration.yml')

      if base.nil? && local.nil?
        raise MissingConfigurationFile.new("Neither config/configuration.yml.example nor config/configuration.yml was found")
      end

      if !base.nil? && !local.nil?
        verify!(base, local)
      end

      @@configuration = Store.new(local || base)
    end

    def load_yml(file)
      path = File.join(local_app.root, file)
      return unless File.exists?(path)
      YAML.load_file(path)[self.env]
    end

    private

    def verify!(base, local)
      missing_keys = base.keys - local.keys
      if missing_keys.any?
        raise MissingConfigurationVariables.new("Following variables are missing in your configuration file: #{missing_keys.join(',')}")
      end
    end
  end
end