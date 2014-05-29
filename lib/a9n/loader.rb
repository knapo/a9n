require 'ostruct'

module A9n
  class Loader
    attr_reader :env, :local_file, :example_file

    def initialize(file_path, env)
      @env = env.to_s
      @local_file = file_path
      @example_file = "#{file_path}.example"
    end

    def get
      @struct ||= load
    end

    def load
      env_example      = self.class.load_yml(example_file, env)
      env_local        = self.class.load_yml(local_file, env)
      default_example  = self.class.load_yml(example_file, "defaults")
      default_local    = self.class.load_yml(local_file, "defaults")

      if env_example.nil? && env_local.nil? && default_example.nil? && default_local.nil?
        raise A9n::MissingConfigurationData.new("Configuration data for *#{env}* env was not found in neither *#{example_file}* nor *#{local_file}*")
      end

      example = A9n::HashExt.merge(default_example, env_example)
      local   = A9n::HashExt.merge(default_local, env_local)

      if !example.nil? && !local.nil?
        verify!(example, local)
      end

      @struct = A9n::Struct.new(local || example)
    end

    def self.load_yml(file_path, env)
      return nil unless File.exists?(file_path)
      yml = YAML.load(ERB.new(File.read(file_path)).result)

      if yml[env].is_a?(::Hash)
        A9n::HashExt.deep_symbolize_keys(yml[env])
      else
        return nil
      end
    end

    private

    def verify!(example, local)
      missing_keys = example.keys - local.keys
      if missing_keys.any?
        raise A9n::MissingConfigurationVariables.new("Following variables are missing in #{local_file} file: #{missing_keys.join(",")}")
      end
    end
  end
end
