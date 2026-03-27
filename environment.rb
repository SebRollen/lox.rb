# frozen_string_literal: true

class Environment
  attr_accessor :enclosing, :values

  def initialize(enclosing = nil)
    @enclosing = enclosing
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

    unless enclosing.nil?
      enclosing.assign(name, value)
      return
    end

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def get(name)
    return values[name.lexeme] if values.key?(name.lexeme)
    return enclosing.get(name) unless enclosing.nil?

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end
end
