require 'forwardable'
require 'pathname'
require 'ostruct'
require 'yaml'
require 'erb'
require 'logger'
require 'a9n/version'
require 'a9n/exceptions'
require 'a9n/struct'
require 'a9n/scope'
require 'a9n/ext/string_inquirer'
require 'a9n/ext/hash'
require 'a9n/yaml_loader'
require 'a9n/loader'

module A9n
  extend SingleForwardable

  EXTENSION_LIST = '{yml,yml.erb,yml.example,yml.erb.example}'.freeze
  STRICT_MODE = 'strict'.freeze
  DEFAULT_LOG_LEVEL = 'info'.freeze

  class << self
    attr_writer :logger

    def env
      @env ||= ::A9n::StringInquirer.new(
        app_env ||
        env_var('APP_ENV') ||
        env_var('RACK_ENV') ||
        env_var('RAILS_ENV') ||
        raise(UnknownEnvError)
      )
    end

    def env=(value)
      @env = ::A9n::StringInquirer.new(value)
    end

    def app_env
      app.env if app.respond_to?(:env)
    end

    def app
      @app ||= rails_app
    end

    def app=(app_instance)
      @app = app_instance
    end

    def root
      @root ||= app_root || root_from_bundle_env || raise(RootNotSetError)
    end

    def app_root
      app.root if app.respond_to?(:root)
    end

    def root_from_bundle_env
      return nil unless ENV['BUNDLE_GEMFILE']

      dir = File.dirname(ENV.fetch('BUNDLE_GEMFILE', nil))

      return nil unless File.directory?(dir)

      Pathname.new(dir)
    end

    def root=(path)
      @root = path.to_s.empty? ? nil : Pathname.new(path.to_s).freeze
    end

    def groups
      ['default', env].compact.freeze
    end

    def rails_app
      defined?(Rails) ? Rails : nil
    end

    def env_var(name, strict: false)
      raise A9n::MissingEnvVariableError, name if strict && !ENV.key?(name)

      if ENV[name].is_a?(::String)
        ENV[name].dup.force_encoding(Encoding::UTF_8).freeze
      else
        ENV[name].dup.freeze
      end
    end

    def default_files
      files  = Dir[root.join("config/{#{A9n::Scope::ROOT_NAMES.join(',')}}.#{EXTENSION_LIST}").to_s]
      files += Dir[root.join("config/a9n/*.#{EXTENSION_LIST}")]
      files.map { |f| f.sub(/.example$/, '') }.uniq.sort
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

    def logger
      @logger ||= ::Logger.new($stdout, level: fetch(:log_level, DEFAULT_LOG_LEVEL))
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

      data
    end

    def absolute_paths_for(files)
      files.map { |file| Pathname.new(file).absolute? ? file : root.join('config', file).to_s }
    end

    def require_local_extension
      return if root.nil?

      local_extension_file = File.join(root, 'config/a9n.rb')

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
