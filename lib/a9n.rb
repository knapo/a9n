require "ostruct"
require "yaml"
require "erb"
require "a9n/version"
require "a9n/exceptions"
require "a9n/struct"
require "a9n/scope"
require "a9n/ext/hash"
require "a9n/loader"

module A9n
  extend SingleForwardable

  EXTENSION_LIST = "{yml,yml.erb,yml.example,yml.erb.example}"
  STRICT_MODE = "strict"

  class << self
    def env
      @env ||= app_env || env_var("RAILS_ENV") || env_var("RACK_ENV") || env_var("APP_ENV")
    end

    def app_env
      app.env if app && app.respond_to?(:env)
    end

    def app
      @app ||= rails_app
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

    def rails_app
      defined?(Rails) ? Rails : nil
    end

    def env_var(name, strict: false)
      fail A9n::MissingEnvVariableError.new(name) if strict && !ENV.key?(name)
      return ENV[name].force_encoding("utf-8") if ENV[name].is_a?(::String)
      ENV[name]
    end

    def default_files
      files  = Dir[root.join("config/#{A9n::Scope::ROOT_NAME}.#{EXTENSION_LIST}").to_s]
      files += Dir[root.join("config/a9n/*.#{EXTENSION_LIST}")]
      files.map{ |f| f.sub(/.example$/,'') }.uniq
    end

    def load(*files)
      require_local_extension
      files = files.empty? ? default_files : absolute_paths_for(files)
      files.map { |file| load_file(file) }
    end

    def storage
      @storage ||= A9n::Struct.new
    end

    def mode
      ENV['A9N_MODE'] || STRICT_MODE
    end

    def strict?
      mode == STRICT_MODE
    end

    def method_missing(name, *args)
      load if storage.empty?
      storage.send(name, *args)
    end

    private

    def load_file(file)
      scope = A9n::Scope.form_file_path(file)
      scope_data = A9n::Loader.new(file, scope, env).get
      setup_scope(scope, scope_data)
    end

    def setup_scope(scope, data)
      if scope.root?
        storage.merge(data)
        def_delegator(:storage, :fetch) unless respond_to?(:fetch)
        define_root_geters(*data.keys)
      else
        storage[scope.name] = data
        define_root_geters(scope.name)
      end
      return data
    end

    def absolute_paths_for(files)
      files.map { |file| Pathname.new(file).absolute? ? file : self.root.join('config', file).to_s }
    end

    def require_local_extension
      return if app.nil? || root.nil?
      local_extension_file = File.join(root, "config/a9n.rb")
      return unless File.exist?(local_extension_file)
      require local_extension_file
    end

    def define_root_geters(*names)
      names.each do |name|
        next if respond_to?(name)
        define_singleton_method(name) { storage.fetch(name) }
      end
    end
  end
end
