module A9n
  class Loader
    attr_reader :scope, :env, :local_file, :example_file

    COMMON_SCOPE = "defaults"

    def initialize(file_path, scope, env)
      @scope = scope
      @env = env.to_s
      @local_file = file_path
      @example_file = "#{file_path}.example"
    end

    def get
      @struct ||= load
    end

    def load
      local_config    = self.class.load_yml(local_file, scope, env)
      example_config  = self.class.load_yml(example_file, scope, env)

      if local_config.nil? && example_config.nil?
        fail A9n::MissingConfigurationDataError.new("Configuration data for *#{env}* env was not found in neither *#{example_file}* nor *#{local_file}*")
      end

      if !local_config.nil? && !example_config.nil?
        verify!(local_config, example_config)
      end

      @struct = A9n::Struct.new(local_config || example_config)
    end

    class << self
      def load_yml(file_path, scope, env)
        return nil unless File.exist?(file_path)
        yml = YAML.load(ERB.new(File.read(file_path)).result)

        common_scope = prepare_yml_scope(yml, scope, COMMON_SCOPE)
        env_scope    = prepare_yml_scope(yml, scope, env)

        A9n::Hash.merge(common_scope, env_scope)
      end

      def prepare_yml_scope(yml, scope, env)
        if yml[env].is_a?(::Hash)
          A9n::Hash.deep_prepare(yml[env], scope)
        else
          nil
        end
      end
    end

    private

    def verify!(local, example)
      missing_keys = example.keys - local.keys
      if missing_keys.any?
        fail A9n::MissingConfigurationVariablesError.new("Following variables are missing in #{local_file} file: #{missing_keys.join(',')}")
      end
    end
  end
end
