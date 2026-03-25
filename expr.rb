class Expr
  def accept(visitor)
    visitor.visit(self)
  end

  class Binary < Expr
    attr_accessor :left, :operator, :right

    def initialize(left, operator, right)
      super()
      @left = left
      @operator = operator
      @right = right
    end
  end

  class Grouping < Expr
    attr_accessor :expression

    def initialize(expression)
      super()
      @expression = expression
    end
  end

  class Literal < Expr
    attr_accessor :value

    def initialize(value)
      super()
      @value = value
    end
  end

  class Unary < Expr
    attr_accessor :operator, :right

    def initialize(operator, right)
      super()
      @operator = operator
      @right = right
    end
  end
end
