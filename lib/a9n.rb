require 'a9n/version'
require 'a9n/struct'
require 'a9n/core_ext/hash'
require 'yaml'
require 'erb'

module A9n
  class ConfigurationNotLoaded < StandardError; end
  class MissingConfigurationFile < StandardError; end
  class MissingConfigurationData < StandardError; end
  class MissingConfigurationVariables < StandardError; end
  class NoSuchConfigurationVariable < StandardError; end
  
  class << self

    def config
      @@configuration ||= load
    end

    def env
      @env ||= local_app_env || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ENV['APP_ENV']
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

    def load
      base  = load_yml('config/configuration.yml.example')
      local = load_yml('config/configuration.yml')

      if base.nil? && local.nil?
        raise MissingConfigurationFile.new("Neither config/configuration.yml.example nor config/configuration.yml was found")
      end

      if !base.nil? && !local.nil?
        verify!(base, local)
      end

      @@configuration = Struct.new(local || base)
    end

    def load_yml(file)
      path = File.join(self.root, file)
      return unless File.exists?(path)
      yml = YAML.load(ERB.new(File.read(path)).result)
      
      if yml[self.env].is_a?(Hash)
        return yml[self.env].deep_symbolize_keys
      else
        raise MissingConfigurationData.new("Configuration data for #{self.env} was not found in #{file}")
      end
    end

    # Fixes rspec issue
    def to_ary
      nil
    end

    def fetch(*args)
      config.fetch(*args)
    end

    def method_missing(name, *args)
      config.send(name, *args)
    end

    private

    def verify!(base, local)
      missing_keys = base.keys - local.keys
      if missing_keys.any?
        raise MissingConfigurationVariables.new("Following variables are missing in your configuration file: #{missing_keys.join(',')}")
      end
    end

    def get_rails
      defined?(Rails) ? Rails : nil
    end
  end
end
