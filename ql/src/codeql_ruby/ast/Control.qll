private import codeql_ruby.AST
private import internal.Control

/**
 * A control expression that can be any of the following:
 * - `case`
 * - `if`/`unless` (including expression-modifier variants)
 * - ternary-if (`?:`)
 * - `while`/`until` (including expression-modifier variants)
 * - `for`
 */
class ControlExpr extends Expr {
  override ControlExpr::Range range;
}

/**
 * A conditional expression: `if`/`unless` (including expression-modifier
 * variants), and ternary-if (`?:`) expressions.
 */
class ConditionalExpr extends Expr {
  override ConditionalExpr::Range range;

  /**
   * Gets the condition expression. For example, the result is `foo` in the
   * following:
   * ```rb
   * if foo
   *   bar = 1
   * end
   * ```
   */
  final Expr getCondition() { result = range.getCondition() }

  /**
   * Gets the branch of this conditional expression that is taken when the
   * condition evaluates to `cond`, if any.
   */
  Expr getBranch(boolean cond) { result = range.getBranch(cond) }
}

/**
 * An `if` or `elsif` expression.
 * ```
 */
class IfOrElsifExpr extends ConditionalExpr {
  override IfOrElsifExpr::Range range;

  /** Gets the 'then' branch of this `if`/`elsif` expression. */
  final ExprSequence getThen() { result = range.getThen() }

  /**
   * Gets the `elsif`/`else` branch of this `if`/`elsif` expression, if any. In
   * the following example, the result is an `ExprSequence` containing `b`.
   * ```rb
   * if foo
   *   a
   * else
   *   b
   * end
   * ```
   * But there is no result for the following:
   * ```rb
   * if foo
   *   a
   * end
   * ```
   * There can be at most one result, since `elsif` branches nest. In the
   * following example, `ifExpr.getElse()` returns an `ElsifExpr`, and the
   * `else` branch is nested inside that. To get the `ExprSequence` for the
   * `else` branch, i.e. the one containing `c`, use
   * `getElse().(ElsifExpr).getElse()`.
   * ```rb
   * if foo
   *   a
   * elsif bar
   *   b
   * else
   *   c
   * end
   * ```
   */
  final Expr getElse() { result = range.getElse() }
}

/**
 * An `if` expression.
 * ```rb
 * if x
 *   y += 1
 * end
 * ```
 */
class IfExpr extends IfOrElsifExpr, @if {
  final override IfExpr::Range range;

  final override string getAPrimaryQlClass() { result = "IfExpr" }

  final override string toString() { result = "if ..." }
}

/**
 * An `elsif` expression.
 * ```rb
 * if x
 *   a += 1
 * elsif y
 *   a += 2
 * end
 * ```
 */
class ElsifExpr extends IfOrElsifExpr, @elsif {
  final override ElsifExpr::Range range;

  final override string getAPrimaryQlClass() { result = "ElsifExpr" }

  final override string toString() { result = "elsif ..." }
}

/**
 * An `unless` expression.
 * ```rb
 * unless x == 0
 *   y /= x
 * end
 * ```
 */
class UnlessExpr extends ConditionalExpr, @unless {
  final override UnlessExpr::Range range;

  final override string getAPrimaryQlClass() { result = "UnlessExpr" }

  final override string toString() { result = "unless ..." }

  /**
   * Gets the 'then' branch of this `unless` expression. In the following
   * example, the result is the `ExprSequence` containing `foo`.
   * ```rb
   * unless a == b then
   *   foo
   * else
   *   bar
   * end
   * ```
   */
  final ExprSequence getThen() { result = range.getThen() }

  /**
   * Gets the 'else' branch of this `unless` expression. In the following
   * example, the result is the `ExprSequence` containing `bar`.
   * ```rb
   * unless a == b then
   *   foo
   * else
   *   bar
   * end
   * ```
   */
  final ExprSequence getElse() { result = range.getElse() }
}

/**
 * An expression modified using `if`.
 * ```rb
 * foo if bar
 * ```
 */
class IfModifierExpr extends ConditionalExpr, @if_modifier {
  final override IfModifierExpr::Range range;

  final override string getAPrimaryQlClass() { result = "IfModifierExpr" }

  final override string toString() { result = "... if ..." }

  /**
   * Gets the expression that is conditionally evaluated. In the following
   * example, the result is the `Expr` for `foo`.
   * ```rb
   * foo if bar
   * ```
   */
  final Expr getExpr() { result = range.getExpr() }
}

/**
 * An expression modified using `unless`.
 * ```rb
 * y /= x unless x == 0
 * ```
 */
class UnlessModifierExpr extends ConditionalExpr, @unless_modifier {
  final override UnlessModifierExpr::Range range;

  final override string getAPrimaryQlClass() { result = "UnlessModifierExpr" }

  final override string toString() { result = "... unless ..." }

  /**
   * Gets the expression that is conditionally evaluated. In the following
   * example, the result is the `Expr` for `foo`.
   * ```rb
   * foo unless bar
   * ```
   */
  final Expr getExpr() { result = range.getExpr() }
}

/**
 * A conditional expression using the ternary (`?:`) operator.
 * ```rb
 * (a > b) ? a : b
 * ```
 */
class TernaryIfExpr extends ConditionalExpr, @conditional {
  final override TernaryIfExpr::Range range;

  final override string getAPrimaryQlClass() { result = "TernaryIfExpr" }

  final override string toString() { result = "... ? ... : ..." }

  /** Gets the 'then' branch of this ternary if expression. */
  final Expr getThen() { result = range.getThen() }

  /** Gets the 'else' branch of this ternary if expression. */
  final Expr getElse() { result = range.getElse() }
}

class CaseExpr extends ControlExpr, @case__ {
  final override CaseExpr::Range range;

  final override string getAPrimaryQlClass() { result = "CaseExpr" }

  final override string toString() { result = "case ..." }

  /**
   * Gets the expression being compared, if any. For example, `foo` in the following example.
   * ```rb
   * case foo
   * when 0
   *   puts 'zero'
   * when 1
   *   puts 'one'
   * end
   * ```
   * There is no result for the following example:
   * ```rb
   * case
   * when a then 0
   * when b then 1
   * else        2
   * end
   * ```
   */
  final Expr getValue() { result = range.getValue() }

  /**
   * Gets the `n`th branch of this case expression, either a `WhenExpr` or an
   * `ExprSequence`.
   */
  final Expr getBranch(int n) { result = range.getBranch(n) }

  /**
   * Gets a branch of this case expression, either a `WhenExpr` or an
   * `ElseExpr`.
   */
  final Expr getABranch() { result = this.getBranch(_) }

  /** Gets a `when` branch of this case expression. */
  final WhenExpr getAWhenBranch() { result = getABranch() }

  /** Gets the `else` branch of this case expression, if any. */
  final ExprSequence getElseBranch() { result = getABranch() }

  /**
   * Gets the number of branches of this case expression.
   */
  final int getNumberOfBranches() { result = count(this.getBranch(_)) }
}

/**
 * A `when` branch of a `case` expression.
 * ```rb
 * case
 * when a > b then x
 * end
 * ```
 */
class WhenExpr extends Expr, @when {
  final override WhenExpr::Range range;

  final override string getAPrimaryQlClass() { result = "WhenExpr" }

  final override string toString() { result = "when ..." }

  /** Gets the body of this case-when expression. */
  final ExprSequence getBody() { result = range.getBody() }

  /**
   * Gets the `n`th pattern (or condition) in this case-when expression. In the
   * following example, the 0th pattern is `x`, the 1st pattern is `y`, and the
   * 2nd pattern is `z`.
   * ```rb
   * case foo
   * when x, y, z
   *   puts 'x/y/z'
   * end
   * ```
   */
  final Expr getPattern(int n) { result = range.getPattern(n) }

  /**
   * Gets a pattern (or condition) in this case-when expression.
   */
  final Expr getAPattern() { result = this.getPattern(_) }

  /**
   * Gets the number of patterns in this case-when expression.
   */
  final int getNumberOfPatterns() { result = count(this.getPattern(_)) }
}

/**
 * A loop. That is, a `for` loop, a `while` or `until` loop, or their
 * expression-modifier variants.
 */
class Loop extends ControlExpr {
  override Loop::Range range;

  /** Gets the body of this loop. */
  Expr getBody() { result = range.getBody() }
}

/**
 * A `while` loop.
 * ```rb
 * while a < b
 *   p a
 *   a += 2
 * end
 * ```
 */
class WhileExpr extends Loop, @while {
  final override WhileExpr::Range range;

  final override string getAPrimaryQlClass() { result = "WhileExpr" }

  final override string toString() { result = "while ..." }

  /** Gets the body of this `while` loop. */
  final override ExprSequence getBody() { result = range.getBody() }

  /** Gets the condition expression of this `while` loop. */
  final Expr getCondition() { result = range.getCondition() }
}

/**
 * An `until` loop.
 * ```rb
 * until a >= b
 *   p a
 *   a += 1
 * end
 * ```
 */
class UntilExpr extends Loop, @until {
  final override UntilExpr::Range range;

  final override string getAPrimaryQlClass() { result = "UntilExpr" }

  final override string toString() { result = "until ..." }

  /** Gets the body of this `until` loop. */
  final override ExprSequence getBody() { result = range.getBody() }

  /** Gets the condition expression of this `until` loop. */
  final Expr getCondition() { result = range.getCondition() }
}

/**
 * An expression looped using the `while` modifier. In the following example,
 * `getCondition` returns the `Expr` for `bar`, and `getBody` returns the
 * `Expr` for `foo`.
 * ```rb
 * foo while bar
 * ```
 */
class WhileModifierExpr extends Loop, @while_modifier {
  final override WhileModifierExpr::Range range;

  final override string getAPrimaryQlClass() { result = "WhileModifierExpr" }

  final override string toString() { result = "... while ..." }

  /** Gets the condition expression of this `while`-modifier. */
  final Expr getCondition() { result = range.getCondition() }
}

/**
 * An expression looped using the `until` modifier. In the following example,
 * `getCondition` returns the `Expr` for `bar`, and `getBody` returns the
 * `Expr` for `foo`.
 * ```rb
 * foo until bar
 * ```
 */
class UntilModifierExpr extends Loop, @until_modifier {
  final override UntilModifierExpr::Range range;

  final override string getAPrimaryQlClass() { result = "UntilModifierExpr" }

  final override string toString() { result = "... until ..." }

  /** Gets the condition expression of this `until`-modifier. */
  final Expr getCondition() { result = range.getCondition() }
}

/**
 * A `for` loop.
 * ```rb
 * for val in 1..n
 *   sum += val
 * end
 * ```
 */
class ForExpr extends Loop, @for {
  final override ForExpr::Range range;

  final override string getAPrimaryQlClass() { result = "ForExpr" }

  final override string toString() { result = "for ... in ..." }

  /** Gets the body of this `for` loop. */
  final override Expr getBody() { result = range.getBody() }

  /** Gets the pattern representing the iteration argument. */
  final Pattern getPattern() { result = range.getPattern() }

  /**
   * Gets the value being iterated over. In the following example, the result
   * is the expression `1..10`:
   * ```rb
   * for n in 1..10 do
   *   puts n
   * end
   * ```
   */
  final Expr getValue() { result = range.getValue() }
}
