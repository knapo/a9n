module A9n
  class Scope
    MAIN_NAME = :configuration

    attr_reader :name

    def initialize(name)
      @name = name.to_sym
    end

    def main?
      name == MAIN_NAME
    end
  end
end
