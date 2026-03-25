class AstPrinter
  def self.print(expr)
    expr.accept(self)
  end

  def self.visit(expr)
    case expr
    when Expr::Binary
      visit_binary_expr(expr)
    when Expr::Grouping
      visit_grouping_expr(expr)
    when Expr::Literal
      visit_literal_expr(expr)
    when Expr::Unary
      visit_unary_expr(expr)
    end
  end

  def self.visit_binary_expr(expr)
    paranthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def self.visit_grouping_expr(expr)
    paranthesize('group', expr.expression)
  end

  def self.visit_literal_expr(expr)
    return 'nil' unless expr.value

    expr.value.to_s
  end

  def self.visit_unary_expr(expr)
    paranthesize(expr.operator.lexeme, expr.right)
  end

  def self.paranthesize(name, *exprs)
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
