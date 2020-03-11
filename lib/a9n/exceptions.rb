module A9n
  Error = Class.new(StandardError)
  ConfigurationNotLoadedError = Class.new(Error)
  MissingConfigurationDataError = Class.new(Error)
  MissingConfigurationVariablesError = Class.new(Error)
  NoSuchConfigurationVariableError = Class.new(Error)
  KeyNotFoundError = Class.new(NoSuchConfigurationVariableError)
  MissingEnvVariableError = Class.new(Error)
  UnknownEnvError = Class.new(Error)
  RootNotSetError = Class.new(Error)
end
