class Parser
  class ParseError < StandardError; end
  attr_accessor :tokens, :current

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []
    statements.append(declaration) until at_end?

    statements
  end

  private

  # expression     → assignment
  def expression
    assignment
  end

  def declaration
    return var_declaration if match(TokenType::VAR)

    statement
  rescue ParseError
    synchronize
    nil
  end

  def statement
    return print_statement if match(TokenType::PRINT)

    expression_statement
  end

  def print_statement
    value = expression
    consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  def var_declaration
    name = consume(TokenType::IDENTIFIER, 'Expect variable name.')

    initializer = nil
    initializer = expression if match(TokenType::EQUAL)
    consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  def expression_statement
    value = expression
    consume(TokenType::SEMICOLON, "Expect ';' after value.")
    Stmt::Expression.new(value)
  end

  def assignment
    expr = equality

    if match(TokenType::EQUAL)
      equals = previous
      value = assignment

      if expr.is_a?(Expr::Variable)
        name = expr.name
        return Expr::Assign.new(name, value)
      end

      error(equals, 'Invalid assignment target.')
    end

    expr
  end

  # equality       → comparison ( ( "!=" | "==" ) comparison )* ;
  def equality
    expr = comparison
    while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  # comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def comparison
    expr = term

    while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  # term           → factor ( ( "-" | "+" ) factor )* ;
  def term
    expr = factor

    while match(TokenType::PLUS, TokenType::MINUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  # factor         → unary ( ( "/" | "*" ) unary )* ;
  def factor
    expr = unary

    while match(TokenType::SLASH, TokenType::STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  # unary          → ( "!" | "-" ) unary | primary ;
  def unary
    if match(TokenType::BANG, TokenType::MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end

    primary
  end

  # primary        → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" ;
  def primary
    return Expr::Literal.new(false) if match(TokenType::FALSE)
    return Expr::Literal.new(true) if match(TokenType::TRUE)
    return Expr::Literal.new(nil) if match(TokenType::NIL)
    return Expr::Literal.new(previous.literal) if match(TokenType::NUMBER, TokenType::STRING)
    return Expr::Variable.new(previous) if match(TokenType::IDENTIFIER)

    if match(TokenType::LEFT_PAREN)
      expr = expression
      consume(TokenType::RIGHT_PAREN, "Expect ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error(peek, 'Expect expression.')
  end

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end

    false
  end

  def consume(type, message)
    return advance if check(type)

    raise error(peek, message)
  end

  def error(token, message)
    Lox.parse_error(token, message)
    ParseError.new
  end

  def synchronize
    advance

    until at_end?
      return if previous.type == TokenType::SEMICOLON

      case peek.type
      when TokenType::CLASS, TokenType::FUN, TokenType::VAR, TokenType::FOR, TokenType::IF, TokenType::WHILE, TokenType::PRINT, TokenType::RETURN
        return
      end

      advance
    end
  end

  def check(type)
    return false if at_end?

    peek.type == type
  end

  def advance
    self.current += 1 unless at_end?
    previous
  end

  def at_end?
    peek.type == TokenType::EOF
  end

  def peek
    tokens[current]
  end

  def previous
    tokens[current - 1]
  end
end
