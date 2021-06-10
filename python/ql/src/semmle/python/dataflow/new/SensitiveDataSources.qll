/**
 * Provides an extension point for for modeling sensitive data, such as secrets, certificates, or passwords.
 * Sensitive data can be interesting to use as data-flow sources in security queries.
 */

private import python
private import semmle.python.dataflow.new.DataFlow
// Need to import `semmle.python.Frameworks` since frameworks can extend `SensitiveDataSource::Range`
private import semmle.python.Frameworks
private import semmle.python.security.internal.SensitiveDataHeuristics as SensitiveDataHeuristics

// We export these explicitly, so we don't also export the `HeuristicNames` module.
class SensitiveDataClassification = SensitiveDataHeuristics::SensitiveDataClassification;

module SensitiveDataClassification = SensitiveDataHeuristics::SensitiveDataClassification;

/**
 * A data flow source of sensitive data, such as secrets, certificates, or passwords.
 *
 * Extend this class to refine existing API models. If you want to model new APIs,
 * extend `SensitiveDataSource::Range` instead.
 */
class SensitiveDataSource extends DataFlow::Node {
  SensitiveDataSource::Range range;

  SensitiveDataSource() { this = range }

  /**
   * Gets the classification of the sensitive data.
   */
  SensitiveDataClassification getClassification() { result = range.getClassification() }
}

/** Provides a class for modeling new sources of sensitive data, such as secrets, certificates, or passwords. */
module SensitiveDataSource {
  /**
   * A data flow source of sensitive data, such as secrets, certificates, or passwords.
   *
   * Extend this class to model new APIs. If you want to refine existing API models,
   * extend `SensitiveDataSource` instead.
   */
  abstract class Range extends DataFlow::Node {
    /**
     * Gets the classification of the sensitive data.
     */
    abstract SensitiveDataClassification getClassification();
  }
}

/** Actual sensitive data modeling */
private module SensitiveDataModeling {
  private import SensitiveDataHeuristics::HeuristicNames

  /**
   * Gets a reference to a function that is considered to be a sensitive source of
   * `classification`.
   */
  private DataFlow::LocalSourceNode sensitiveFunction(
    DataFlow::TypeTracker t, SensitiveDataClassification classification
  ) {
    t.start() and
    exists(Function f |
      nameIndicatesSensitiveData(f.getName(), classification) and
      result.asExpr() = f.getDefinition()
    )
    or
    exists(DataFlow::TypeTracker t2 | result = sensitiveFunction(t2, classification).track(t2, t))
  }

  /**
   * Gets a reference to a function that is considered to be a sensitive source of
   * `classification`.
   */
  DataFlow::Node sensitiveFunction(SensitiveDataClassification classification) {
    sensitiveFunction(DataFlow::TypeTracker::end(), classification).flowsTo(result)
  }

  /**
   * Gets a reference to a string constant that, if used as the key in a lookup,
   * indicates the presence of sensitive data with `classification`.
   */
  private DataFlow::LocalSourceNode sensitiveLookupStringConst(
    DataFlow::TypeTracker t, SensitiveDataClassification classification
  ) {
    t.start() and
    nameIndicatesSensitiveData(result.asExpr().(StrConst).getText(), classification)
    or
    exists(DataFlow::TypeTracker t2 |
      result = sensitiveLookupStringConst(t2, classification).track(t2, t)
    )
  }

  /**
   * Gets a reference to a string constant that, if used as the key in a lookup,
   * indicates the presence of sensitive data with `classification`.
   */
  DataFlow::Node sensitiveLookupStringConst(SensitiveDataClassification classification) {
    sensitiveLookupStringConst(DataFlow::TypeTracker::end(), classification).flowsTo(result)
  }

  /** A function call that is considered a source of sensitive data. */
  class SensitiveFunctionCall extends SensitiveDataSource::Range, DataFlow::CallCfgNode {
    SensitiveDataClassification classification;

    SensitiveFunctionCall() {
      this.getFunction() = sensitiveFunction(classification)
      or
      nameIndicatesSensitiveData(this.getFunction().asCfgNode().(NameNode).getId(), classification)
    }

    override SensitiveDataClassification getClassification() { result = classification }
  }

  /**
   * Any kind of variable assignment (also including with/for) where the name indicates
   * it contains sensitive data.
   *
   * Note: We _could_ make any access to a variable with a sensitive name a source of
   * sensitive data, but to make path explanations in data-flow/taint-tracking good,
   * we don't want that, since it works against allowing users to understand the flow
   * in the program (which is the whole point).
   *
   * Note: To make data-flow/taint-tracking work, the expression that is _assigned_ to
   * the variable is marked as the source (as compared to marking the variable as the
   * source).
   */
  class SensitiveVariableAssignment extends SensitiveDataSource::Range {
    SensitiveDataClassification classification;

    SensitiveVariableAssignment() {
      exists(DefinitionNode def |
        nameIndicatesSensitiveData(def.(NameNode).getId(), classification) and
        (
          this.asCfgNode() = def.getValue()
          or
          this.asCfgNode() = def.getValue().(ForNode).getSequence()
        ) and
        not this.asExpr() instanceof FunctionExpr and
        not this.asExpr() instanceof ClassExpr
      )
      or
      exists(With with |
        nameIndicatesSensitiveData(with.getOptionalVars().(Name).getId(), classification) and
        this.asExpr() = with.getContextExpr()
      )
    }

    override SensitiveDataClassification getClassification() { result = classification }
  }

  /** An attribute access that is considered a source of sensitive data. */
  class SensitiveAttributeAccess extends SensitiveDataSource::Range {
    SensitiveDataClassification classification;

    SensitiveAttributeAccess() {
      // Things like `foo.<sensitive-name>` or `from <module> import <sensitive-name>`
      // I considered excluding any `from ... import something_sensitive`, but then realized that
      // we should flag up `form ... import password as ...` as a password
      nameIndicatesSensitiveData(this.(DataFlow::AttrRead).getAttributeName(), classification)
      or
      // Things like `getattr(foo, <reference-to-string>)`
      this.(DataFlow::AttrRead).getAttributeNameExpr() = sensitiveLookupStringConst(classification)
    }

    override SensitiveDataClassification getClassification() { result = classification }
  }

  /** A subscript, where the key indicates the result will be sensitive data. */
  class SensitiveSubscript extends SensitiveDataSource::Range {
    SensitiveDataClassification classification;

    SensitiveSubscript() {
      this.asCfgNode().(SubscriptNode).getIndex() =
        sensitiveLookupStringConst(classification).asCfgNode()
    }

    override SensitiveDataClassification getClassification() { result = classification }
  }

  /** A call to `get` on an object, where the key indicates the result will be sensitive data. */
  class SensitiveGetCall extends SensitiveDataSource::Range, DataFlow::CallCfgNode {
    SensitiveDataClassification classification;

    SensitiveGetCall() {
      this.getFunction().asCfgNode().(AttrNode).getName() = "get" and
      this.getArg(0) = sensitiveLookupStringConst(classification)
    }

    override SensitiveDataClassification getClassification() { result = classification }
  }

  /** A parameter where the name indicates it will receive sensitive data. */
  class SensitiveParameter extends SensitiveDataSource::Range, DataFlow::ParameterNode {
    SensitiveDataClassification classification;

    SensitiveParameter() {
      nameIndicatesSensitiveData(this.getParameter().getName(), classification)
    }

    override SensitiveDataClassification getClassification() { result = classification }
  }
}
