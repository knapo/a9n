module A9n
  class ConfigurationNotLoadedError < StandardError; end
  class MissingConfigurationDataError < StandardError; end
  class MissingConfigurationVariablesError < StandardError; end
  class NoSuchConfigurationVariableError < StandardError; end
  class MissingEnvVariableError < StandardError; end
end
