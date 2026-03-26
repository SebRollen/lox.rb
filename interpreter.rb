class Interpreter
  def interpret(expression)
    value = evaluate(expression)
    puts stringify(value)
  rescue RuntimeError => e
    Lox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::BANG
      !truthy?(right)
    when TokenType::MINUS
      check_number_operand(expr.operator, right)
      -right.as_f
    end
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::GREATER
      check_number_operands(expr.operator, left, right)
      left > right
    when TokenType::GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left >= right
    when TokenType::LESS
      check_number_operands(expr.operator, left, right)
      left < right
    when TokenType::LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left <= right
    when TokenType::BANG_EQUAL
      !equal?(left, right)
    when TokenType::EQUAL_EQUAL
      equal?(left, right)
    when TokenType::MINUS
      check_number_operands(expr.operator, left, right)
      left.to_f - right.to_f
    when TokenType::SLASH
      check_number_operands(expr.operator, left, right)
      left / right.to_f
    when TokenType::STAR
      check_number_operands(expr.operator, left, right)
      left.to_f * right.to_f
    when TokenType::PLUS
      if left.is_a?(Float) && right.is_a?(Float)
        left + right
      elsif left.is_a?(String) && right.is_a?(String)
        left.concat(right)
      else
        raise RuntimeError.new(expr.operator, 'Operands must be two numbers or two strings.')
      end
    end
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def check_number_operand(operator, operand)
    return if operand.is_a?(Float)

    raise RuntimeError.new(operator, 'Operand must be a number.')
  end

  def check_number_operands(operator, left, right)
    return if left.is_a?(Float) && right.is_a?(Float)

    raise RuntimeError.new(operator, 'Operands must be numbers.')
  end

  def truthy?(object)
    return false if object.nil?
    return object if [true, false].include?(object)

    true
  end

  def equal?(a, b)
    return true if a.nil? && b.nil?
    return false if a.nil?

    a == b
  end

  def stringify(object)
    return 'nil' if object.nil?

    if object.is_a?(Float)
      text = object.to_s
      text = text[0...text.length - 2] if text.end_with?('.0')
      return text
    end

    object.to_s
  end
end
