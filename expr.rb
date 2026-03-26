class Expr
  class Assign < Expr
    attr_accessor :name, :value

    def initialize(name, value)
      super()
      @name = name
      @value = value
    end

    def accept(visitor)
      visitor.visit_assign_expr(self)
    end
  end

  class Binary < Expr
    attr_accessor :left, :operator, :right

    def initialize(left, operator, right)
      super()
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_binary_expr(self)
    end
  end

  class Grouping < Expr
    attr_accessor :expression

    def initialize(expression)
      super()
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_grouping_expr(self)
    end
  end

  class Literal < Expr
    attr_accessor :value

    def initialize(value)
      super()
      @value = value
    end

    def accept(visitor)
      visitor.visit_literal_expr(self)
    end
  end

  class Unary < Expr
    attr_accessor :operator, :right

    def initialize(operator, right)
      super()
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_unary_expr(self)
    end
  end

  class Variable < Expr
    attr_accessor :name

    def initialize(name)
      super()
      @name = name
    end

    def accept(visitor)
      visitor.visit_variable_expr(self)
    end
  end
end
