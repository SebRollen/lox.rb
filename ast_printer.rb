class AstPrinter
  def print(expr)
    expr.accept(self)
  end

  def visit_binary_expr(expr)
    paranthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping_expr(expr)
    paranthesize('group', expr.expression)
  end

  def visit_literal_expr(expr)
    return 'nil' if expr.value.nil?

    expr.value.to_s
  end

  def visit_unary_expr(expr)
    paranthesize(expr.operator.lexeme, expr.right)
  end

  def paranthesize(name, *exprs)
    builder = ''
    builder << '('
    builder << name
    exprs.each do |expr|
      builder << ' '
      builder << expr.accept(self)
    end
    builder << ')'
    builder
  end
end
