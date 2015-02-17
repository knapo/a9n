require "a9n/version"
require "a9n/struct"
require "a9n/ext/hash"
require "a9n/loader"
require "yaml"
require "erb"

module A9n
  extend SingleForwardable

  class ConfigurationNotLoaded < StandardError; end
  class MissingConfigurationData < StandardError; end
  class MissingConfigurationVariables < StandardError; end
  class NoSuchConfigurationVariable < StandardError; end

  DEFAULT_SCOPE = :configuration
  EXTENSION_LIST = "{yml,yml.erb,yml.example,yml.erb.example}"

  def_delegators :configuration, :fetch

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

    def default_files
      files  = Dir[root.join("config/#{DEFAULT_SCOPE}.#{EXTENSION_LIST}").to_s]
      files += Dir[root.join("config/a9n/*.#{EXTENSION_LIST}")]
      files.map{ |f| f.sub(/.example$/,'') }.uniq
    end

    def load(*files)
      files = files.empty? ? default_files : get_absolute_paths_for(files)
      files.map { |file| store_values(file) }
    end

    def method_missing(name, *args)
      load if configuration.blank?
      configuration.send(name)
    end

    def configuration
      @@configuration ||= A9n::Struct.new
    end

    private

    def store_values(file)
      A9n::Loader.new(file, env).get.tap do |data|
        store_key = File.basename(file.to_s).split('.').first
        data_keys = Array(default_scope?(store_key) ? data.keys : store_key.to_sym)

        data_keys.each do |key|
          configuration[key] = (default_scope?(store_key) ? data.send(key) : data)
        end

        self.def_delegators :configuration, *data_keys
      end
    end

    def get_absolute_paths_for(files)
      files.map { |file| Pathname.new(file).absolute? ? file : self.root.join('config', file).to_s }
    end

    def default_scope?(scope)
      scope.to_s == DEFAULT_SCOPE.to_s
    end
  end
end
