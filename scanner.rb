# frozen_string_literal: true

class Scanner
  attr_accessor :source, :tokens, :start, :current, :line

  KEYWORDS = {
    'and' => TokenType::AND,
    'class' => TokenType::CLASS,
    'else' => TokenType::ELSE,
    'false' => TokenType::FALSE,
    'for' => TokenType::FOR,
    'fun' => TokenType::FUN,
    'if' => TokenType::IF,
    'nil' => TokenType::NIL,
    'or' => TokenType::OR,
    'print' => TokenType::PRINT,
    'return' => TokenType::RETURN,
    'super' => TokenType::SUPER,
    'this' => TokenType::THIS,
    'true' => TokenType::TRUE,
    'var' => TokenType::VAR,
    'while' => TokenType::WHILE
  }.freeze

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end?
      self.start = current
      scan_token
    end

    tokens << Token.new(TokenType::EOF, '', nil, line)
    tokens
  end

  private

  def at_end?
    current >= source.length
  end

  def scan_token
    c = advance

    case c
    when '('
      add_token(TokenType::LEFT_PAREN)
    when ')'
      add_token(TokenType::RIGHT_PAREN)
    when '{'
      add_token(TokenType::LEFT_BRACE)
    when '}'
      add_token(TokenType::RIGHT_BRACE)
    when ','
      add_token(TokenType::COMMA)
    when '.'
      add_token(TokenType::DOT)
    when '-'
      add_token(TokenType::MINUS)
    when '+'
      add_token(TokenType::PLUS)
    when ';'
      add_token(TokenType::SEMICOLON)
    when '*'
      add_token(TokenType::STAR)
    when '!'
      add_token(match('=') ? TokenType::BANG_EQUAL : TokenType::BANG)
    when '='
      add_token(match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
    when '<'
      add_token(match('=') ? TokenType::LESS_EQUAL : TokenType::LESS)
    when '>'
      add_token(match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER)
    when '/'
      if match('/')
        # A comment, goes til the end of the line
        advance until peek == "\n" || at_end?
      else
        add_token(TokenType::SLASH)
      end
    when ' ', "\r", "\t"
      # ignore whitespace
    when "\n"
      self.line += 1
    when '"'
      string
    else
      if digit?(c)
        number
      elsif alpha?(c)
        identifier
      else
        Lox.error(line, 'Unexpected character.')
      end
    end
  end

  def peek
    return '\0' if at_end?

    source[current]
  end

  def peek_next
    return '\0' if current + 1 >= source.length

    source[current + 1]
  end

  def match(expected)
    return false if at_end?
    return false unless source[current] == expected

    self.current += 1
    true
  end

  def advance
    char = source[current]
    self.current += 1
    char
  end

  def string
    until peek == '"' || at_end?
      self.line += 1 if peek == "\n"
      advance
    end

    if at_end?
      Lox.error(line, 'Unterminated string.')
      return
    end

    # the closing "
    advance

    value = source[(start + 1)...(current - 1)]
    add_token(TokenType::STRING, value)
  end

  def digit?(c)
    c >= '0' && c <= '9'
  end

  def alpha?(c)
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  end

  def alphanumeric?(c)
    alpha?(c) || digit?(c)
  end

  def number
    advance while digit?(peek)

    if peek == '.' && digit?(peek_next)
      # consume '.'
      advance

      advance while digit?(peek)
    end

    add_token(TokenType::NUMBER, source[start...current].to_f)
  end

  def identifier
    advance while alphanumeric?(peek)

    text = source[start...current]
    type = KEYWORDS[text]
    type ||= TokenType::IDENTIFIER
    add_token(type)
  end

  def add_token(type, literal = nil)
    text = source[start...current]
    tokens.push(Token.new(type, text, literal, line))
  end
end
