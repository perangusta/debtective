# frozen_string_literal: true

module ApplicationHelper
  UNUSED_CONST = "I am never used"
  CONST_USED_ONCE = 42
  CONST_LAMBDA = ->(x) { x + 1 }

  def unused_helper
    x = CONST_USED_ONCE + 1
    CONST_LAMBDA[x]
    CONST_LAMBDA.call(x)
  end

  def helper_used_once(arg1, arg2)
    arg1 + arg2
  end

  def helper_used_twice(kwd: nil)
    kwd + 1
  end
end
