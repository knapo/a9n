module A9n
  class YamlLoader
    def self.load(file_path)
      kwargs = RUBY_VERSION >= '3.1.0' ? { aliases: true } : {}
      YAML.load(ERB.new(File.read(file_path)).result, **kwargs)
    end
  end
end
