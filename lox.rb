#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require_relative 'token'
require_relative 'scanner'
require_relative 'expr'
require_relative 'ast_printer'

module Lox
  @had_error = false

  def self.run_file(file)
    text = File.read(file)
    run(text)

    return unless @had_error

    exit(65)
  end

  def self.run_prompt
    loop do
      print '> '
      $stdout.flush
      line = gets&.chomp
      break unless line

      run(line)
      @had_error = false
    end
  end

  def self.run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each do |token|
      puts token
    end
  end

  def self.error(line, message)
    report(line, '', message)
  end

  def self.report(line, where, message)
    puts("[line #{line}] Error#{where}: #{message}")
    @had_error = true
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
