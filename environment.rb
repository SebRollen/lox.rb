# frozen_string_literal: true

class Environment
  attr_accessor :values

  def initialize
    @values = {}
  end

  def define(name, value)
    values[name] = value
  end

  def assign(name, value)
    if values.key?(name.lexeme)
      values[name.lexeme] = value
      return
    end

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def get(name)
    return values[name.lexeme] if values.key?(name.lexeme)

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end
end
