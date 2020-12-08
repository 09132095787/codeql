/**
 * Provides classes representing control flow completions.
 *
 * A completion represents how a statement or expression terminates.
 */

private import codeql_ruby.ast.internal.TreeSitter::Generated
private import codeql_ruby.controlflow.ControlFlowGraph
private import AstNodes
private import ControlFlowGraphImpl
private import NonReturning
private import SuccessorTypes

private newtype TCompletion =
  TSimpleCompletion() or
  TBooleanCompletion(boolean b) { b in [false, true] } or
  TEmptinessCompletion(boolean isEmpty) { isEmpty in [false, true] } or
  TMatchingCompletion(boolean isMatch) { isMatch in [false, true] } or
  TReturnCompletion() or
  TBreakCompletion() or
  TNextCompletion() or
  TRedoCompletion() or
  TRetryCompletion() or
  TRaiseCompletion() or // TODO: Add exception type?
  TExitCompletion() or
  TNestedCompletion(Completion inner, Completion outer, int nestLevel) {
    inner = TBreakCompletion() and
    outer instanceof NonNestedNormalCompletion and
    nestLevel = 0
    or
    inner instanceof NormalCompletion and
    nestedEnsureCompletion(outer, nestLevel)
  }

pragma[noinline]
private predicate nestedEnsureCompletion(Completion outer, int nestLevel) {
  (
    outer = TReturnCompletion()
    or
    outer = TBreakCompletion()
    or
    outer = TNextCompletion()
    or
    outer = TRedoCompletion()
    or
    outer = TRetryCompletion()
    or
    outer = TRaiseCompletion()
    or
    outer = TExitCompletion()
  ) and
  nestLevel = any(Trees::RescueEnsureBlockTree t).nestLevel()
}

pragma[noinline]
private predicate completionIsValidForStmt(AstNode n, Completion c) {
  n instanceof Break and
  c = TBreakCompletion()
  or
  n instanceof Next and
  c = TNextCompletion()
  or
  n instanceof Redo and
  c = TRedoCompletion()
  or
  n instanceof Return and
  c = TReturnCompletion()
}

/** A completion of a statement or an expression. */
abstract class Completion extends TCompletion {
  /** Holds if this completion is valid for node `n`. */
  predicate isValidFor(AstNode n) {
    this = n.(NonReturningCall).getACompletion()
    or
    completionIsValidForStmt(n, this)
    or
    mustHaveBooleanCompletion(n) and
    (
      exists(boolean value | isBooleanConstant(n, value) | this = TBooleanCompletion(value))
      or
      not isBooleanConstant(n, _) and
      this = TBooleanCompletion(_)
    )
    or
    mustHaveMatchingCompletion(n) and
    this = TMatchingCompletion(_)
    or
    n = any(RescueModifier parent).getBody() and this = TRaiseCompletion()
    or
    not n instanceof NonReturningCall and
    not completionIsValidForStmt(n, _) and
    not mustHaveBooleanCompletion(n) and
    not mustHaveMatchingCompletion(n) and
    this = TSimpleCompletion()
  }

  /**
   * Holds if this completion will continue a loop when it is the completion
   * of a loop body.
   */
  predicate continuesLoop() {
    this instanceof NormalCompletion or
    this instanceof NextCompletion
  }

  /**
   * Gets the inner completion. This is either the inner completion,
   * when the completion is nested, or the completion itself.
   */
  Completion getInnerCompletion() { result = this }

  /**
   * Gets the outer completion. This is either the outer completion,
   * when the completion is nested, or the completion itself.
   */
  Completion getOuterCompletion() { result = this }

  /** Gets a successor type that matches this completion. */
  abstract SuccessorType getAMatchingSuccessorType();

  /** Gets a textual representation of this completion. */
  abstract string toString();
}

/** Holds if node `n` has the Boolean constant value `value`. */
private predicate isBooleanConstant(AstNode n, boolean value) {
  mustHaveBooleanCompletion(n) and
  (
    n instanceof True and
    value = true
    or
    n instanceof False and
    value = false
  )
}

/**
 * Holds if a normal completion of `n` must be a Boolean completion.
 */
private predicate mustHaveBooleanCompletion(AstNode n) {
  inBooleanContext(n) and
  not n instanceof NonReturningCall
}

/**
 * Holds if `n` is used in a Boolean context. That is, the value
 * that `n` evaluates to determines a true/false branch successor.
 */
private predicate inBooleanContext(AstNode n) {
  n = any(IfElsifAstNode parent).getConditionNode()
  or
  n = any(ConditionalLoopAstNode parent).getConditionNode()
  or
  exists(LogicalAndAstNode parent |
    n = parent.getLeft()
    or
    inBooleanContext(parent) and
    n = parent.getRight()
  )
  or
  exists(LogicalOrAstNode parent |
    n = parent.getLeft()
    or
    inBooleanContext(parent) and
    n = parent.getRight()
  )
  or
  n = any(LogicalNotAstNode parent | inBooleanContext(parent)).getOperand()
  or
  n = any(ParenthesizedStatement parent | inBooleanContext(parent)).getChild()
  or
  exists(Case c, When w |
    not exists(c.getValue()) and
    c.getChild(_) = w and
    w.getPattern(_).getChild() = n
  )
}

/**
 * Holds if a normal completion of `n` must be a matching completion.
 */
private predicate mustHaveMatchingCompletion(AstNode n) {
  inMatchingContext(n) and
  not n instanceof NonReturningCall
}

/**
 * Holds if `n` is used in a matching context. That is, whether or
 * not the value of `n` matches, determines the successor.
 */
private predicate inMatchingContext(AstNode n) {
  n = any(Rescue r).getExceptions().getChild(_)
  or
  exists(Case c, When w |
    exists(c.getValue()) and
    c.getChild(_) = w and
    w.getPattern(_).getChild() = n
  )
}

/**
 * A completion that represents normal evaluation of a statement or an
 * expression.
 */
abstract class NormalCompletion extends Completion { }

abstract private class NonNestedNormalCompletion extends NormalCompletion { }

/** A simple (normal) completion. */
class SimpleCompletion extends NonNestedNormalCompletion, TSimpleCompletion {
  override NormalSuccessor getAMatchingSuccessorType() { any() }

  override string toString() { result = "simple" }
}

/**
 * A completion that represents evaluation of an expression, whose value determines
 * the successor. Either a Boolean completion (`BooleanCompletion`), an emptiness
 * completion (`EmptinessCompletion`), or a matching completion (`MatchingCompletion`).
 */
abstract class ConditionalCompletion extends NonNestedNormalCompletion {
  /** Gets the Boolean value of this conditional completion. */
  abstract boolean getValue();
}

/**
 * A completion that represents evaluation of an expression
 * with a Boolean value.
 */
class BooleanCompletion extends ConditionalCompletion, TBooleanCompletion {
  private boolean value;

  BooleanCompletion() { this = TBooleanCompletion(value) }

  override boolean getValue() { result = value }

  /** Gets the dual Boolean completion. */
  BooleanCompletion getDual() { result = TBooleanCompletion(value.booleanNot()) }

  override BooleanSuccessor getAMatchingSuccessorType() { result.getValue() = value }

  override string toString() { result = value.toString() }
}

/** A Boolean `true` completion. */
class TrueCompletion extends BooleanCompletion {
  TrueCompletion() { this.getValue() = true }
}

/** A Boolean `false` completion. */
class FalseCompletion extends BooleanCompletion {
  FalseCompletion() { this.getValue() = false }
}

/**
 * A completion that represents evaluation of an emptiness test, for example
 * a test in a `for in` statement.
 */
class EmptinessCompletion extends ConditionalCompletion, TEmptinessCompletion {
  private boolean value;

  EmptinessCompletion() { this = TEmptinessCompletion(value) }

  override boolean getValue() { result = value }

  override EmptinessSuccessor getAMatchingSuccessorType() { result.getValue() = value }

  override string toString() { if value = true then result = "empty" else result = "non-empty" }
}

/**
 * A completion that represents evaluation of a matching test, for example
 * a test in a `rescue` statement.
 */
class MatchingCompletion extends ConditionalCompletion, TMatchingCompletion {
  private boolean value;

  MatchingCompletion() { this = TMatchingCompletion(value) }

  override boolean getValue() { result = value }

  override MatchingSuccessor getAMatchingSuccessorType() { result.getValue() = value }

  override string toString() { if value = true then result = "match" else result = "no-match" }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in a return.
 */
class ReturnCompletion extends Completion {
  ReturnCompletion() {
    this = TReturnCompletion() or
    this = TNestedCompletion(_, TReturnCompletion(), _)
  }

  override ReturnSuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TReturnCompletion() and result = "return"
  }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in a break from a loop.
 */
class BreakCompletion extends Completion {
  BreakCompletion() {
    this = TBreakCompletion() or
    this = TNestedCompletion(_, TBreakCompletion(), _)
  }

  override BreakSuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TBreakCompletion() and result = "break"
  }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in a continuation of a loop.
 */
class NextCompletion extends Completion {
  NextCompletion() {
    this = TNextCompletion() or
    this = TNestedCompletion(_, TNextCompletion(), _)
  }

  override NextSuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TNextCompletion() and result = "next"
  }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in a redo of a loop iteration.
 */
class RedoCompletion extends Completion {
  RedoCompletion() {
    this = TRedoCompletion() or
    this = TNestedCompletion(_, TRedoCompletion(), _)
  }

  override RedoSuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TRedoCompletion() and result = "redo"
  }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in a retry.
 */
class RetryCompletion extends Completion {
  RetryCompletion() {
    this = TRetryCompletion() or
    this = TNestedCompletion(_, TRetryCompletion(), _)
  }

  override RetrySuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TRetryCompletion() and result = "retry"
  }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in a thrown exception.
 */
class RaiseCompletion extends Completion {
  RaiseCompletion() {
    this = TRaiseCompletion() or
    this = TNestedCompletion(_, TRaiseCompletion(), _)
  }

  override RaiseSuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TRaiseCompletion() and result = "raise"
  }
}

/**
 * A completion that represents evaluation of a statement or an
 * expression resulting in an abort/exit.
 */
class ExitCompletion extends Completion {
  ExitCompletion() {
    this = TExitCompletion() or
    this = TNestedCompletion(_, TExitCompletion(), _)
  }

  override ExitSuccessor getAMatchingSuccessorType() { any() }

  override string toString() {
    // `NestedCompletion` defines `toString()` for the other case
    this = TExitCompletion() and result = "exit"
  }
}

/**
 * A nested completion. For example, in
 *
 * ```rb
 * def m
 *   while x >= 0
 *     x -= 1
 *     if num > 100
 *       break
 *     end
 *   end
 *   puts "done"
 * end
 * ```
 *
 * the `while` loop can have a nested completion where the inner completion
 * is a `break` and the outer completion is a simple successor.
 */
abstract class NestedCompletion extends Completion, TNestedCompletion {
  Completion inner;
  Completion outer;
  int nestLevel;

  NestedCompletion() { this = TNestedCompletion(inner, outer, nestLevel) }

  /** Gets a completion that is compatible with the inner completion. */
  abstract Completion getAnInnerCompatibleCompletion();

  /** Gets the level of this nested completion. */
  final int getNestLevel() { result = nestLevel }

  override string toString() { result = outer + " [" + inner + "] (" + nestLevel + ")" }
}

class NestedBreakCompletion extends NormalCompletion, NestedCompletion {
  NestedBreakCompletion() {
    inner = TBreakCompletion() and
    outer instanceof NonNestedNormalCompletion
  }

  override BreakCompletion getInnerCompletion() { result = inner }

  override NonNestedNormalCompletion getOuterCompletion() { result = outer }

  override Completion getAnInnerCompatibleCompletion() {
    result = inner and
    outer = TSimpleCompletion()
    or
    result = TNestedCompletion(outer, inner, _)
  }

  override SuccessorType getAMatchingSuccessorType() {
    outer instanceof SimpleCompletion and
    result instanceof BreakSuccessor
    or
    result = outer.(ConditionalCompletion).getAMatchingSuccessorType()
  }
}

class NestedEnsureCompletion extends NestedCompletion {
  NestedEnsureCompletion() {
    inner instanceof NormalCompletion and
    nestedEnsureCompletion(outer, nestLevel)
  }

  override NormalCompletion getInnerCompletion() { result = inner }

  override Completion getOuterCompletion() { result = outer }

  override Completion getAnInnerCompatibleCompletion() {
    result.getOuterCompletion() = this.getInnerCompletion()
  }

  override SuccessorType getAMatchingSuccessorType() { none() }
}
