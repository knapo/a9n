require "a9n/version"
require "a9n/struct"
require "a9n/scope"
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

  EXTENSION_LIST = "{yml,yml.erb,yml.example,yml.erb.example}"

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
      @root ||= app_root
    end

    def app_root
      app.root if app && app.respond_to?(:root)
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
      files  = Dir[root.join("config/#{A9n::Scope::MAIN_NAME}.#{EXTENSION_LIST}").to_s]
      files += Dir[root.join("config/a9n/*.#{EXTENSION_LIST}")]
      files.map{ |f| f.sub(/.example$/,'') }.uniq
    end

    def load(*files)
      require_local_extension
      files = files.empty? ? default_files : get_absolute_paths_for(files)
      files.map { |file| load_file(file) }
    end

    def storage
      @storage ||= A9n::Struct.new
    end

    def method_missing(name, *args)
      load if storage.empty?
      storage.send(name, *args)
    end

    private

    def load_file(file)
      scope = A9n::Scope.form_file_path(file)
      scope_data = A9n::Loader.new(file, env).get
      setup_scope(scope, scope_data)
    end

    def setup_scope(scope, data)
      if scope.main?
        storage.merge(data)
        def_delegator :storage, :fetch
        def_delegators :storage, *data.keys
      else
        storage[scope.name] = data
        def_delegator :storage, scope.name
      end
      return data
    end

    def scope_name_from_file(file)
      File.basename(file.to_s).split('.').first.to_sym
    end

    def get_absolute_paths_for(files)
      files.map { |file| Pathname.new(file).absolute? ? file : self.root.join('config', file).to_s }
    end

    def require_local_extension
      return if app.nil? || root.nil?
      local_extension_file = File.join(root, "config/a9n.rb")
      return unless File.exists?(local_extension_file)
      require local_extension_file
    end
  end
end
