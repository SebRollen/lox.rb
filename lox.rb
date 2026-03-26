#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require_relative 'runtime_error'
require_relative 'token'
require_relative 'scanner'
require_relative 'parser'
require_relative 'interpreter'
require_relative 'expr'
require_relative 'ast_printer'

module Lox
  @had_error = false
  @had_runtime_error = false
  @interpreter = Interpreter.new

  def self.run_file(file)
    text = File.read(file)
    run(text)

    exit(65) if @had_error
    exit(70) if @had_runtime_error
  end

  def self.run_prompt
    loop do
      print '> '
      $stdout.flush
      line = gets&.chomp
      break unless line
      break if line == 'exit'

      run(line)
      @had_error = false
    end
  end

  def self.run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens
    parser = Parser.new(tokens)
    expression = parser.parse

    return if @had_error

    puts @interpreter.interpret(expression)
  end

  def self.error(line, message)
    report(line, '', message)
  end

  def self.runtime_error(error)
    puts "#{error.message}\n[line #{error.token.line}]"
    @had_runtime_error = true
  end

  def self.report(line, where, message)
    puts("[line #{line}] Error#{where}: #{message}")
    @had_error = true
  end

  def self.parse_error(token, message)
    if token.type == TokenType::EOF
      report(token.line, ' at end', message)
    else
      report(token.line, " at '#{token.lexeme}'", message)
    end
  end
end

def main
  if ARGV.length > 1
    puts 'Usage: rlox [script]'
    exit(64)
  elsif ARGV.length == 1
    Lox.run_file ARGV[0]
  else
    Lox.run_prompt
  end
end

main if __FILE__ == $PROGRAM_NAME
