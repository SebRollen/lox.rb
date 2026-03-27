# frozen_string_literal: true

class Stmt
  class Block < Stmt
    attr_accessor :statements

    def initialize(statements)
      super()
      @statements = statements
    end

    def accept(visitor)
      visitor.visit_block_stmt(self)
    end
  end

  class Expression < Stmt
    attr_accessor :expression

    def initialize(expression)
      super()
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_expression_stmt(self)
    end
  end

  class Print < Stmt
    attr_accessor :expression

    def initialize(expression)
      super()
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_print_stmt(self)
    end
  end

  class Var < Stmt
    attr_accessor :name, :initializer

    def initialize(name, initializer)
      super()
      @name = name
      @initializer = initializer
    end

    def accept(visitor)
      visitor.visit_var_statement(self)
    end
  end
end
