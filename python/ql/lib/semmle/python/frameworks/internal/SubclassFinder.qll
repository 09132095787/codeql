/**
 * INTERNAL: Do not use.
 *
 * Has predicates to help find subclasses in library code. Should only be used to aid in
 * the manual library modeling process,
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.dataflow.new.internal.ImportResolution
private import semmle.python.ApiGraphs
private import semmle.python.filters.Tests
private import semmle.python.Module

// very much inspired by the draft at https://github.com/github/codeql/pull/5632
module NotExposed {
  // Instructions:
  // This needs to be automated better, but for this prototype, here are some rough instructions:
  // 0) get a database of the library you are about to model
  // 1) fill out the `getAlreadyModeledClass` body below
  // 2) quick-eval the `quickEvalMe` predicate below, and copy the output to your modeling predicate
  predicate quickEvalMe(string newImport) {
    newImport =
      "// imports generated by python/frameworks/internal/SubclassFinder.qll\n" + "this = API::" +
        concat(string newModelFullyQualified |
          newModel(any(FindSubclassesSpec spec), newModelFullyQualified, _, _, _)
        |
          fullyQualifiedToApiGraphPath(newModelFullyQualified), " or this = API::"
        )
  }

  // ---------------------------------------------------------------------------
  // Implementation below
  // ---------------------------------------------------------------------------
  //
  // We are looking to find all subclassed of the already modeled classes, and ideally
  // we would identify an `API::Node` for each (then `toString` would give the API
  // path).
  //
  // An inherent problem with API graphs is that there doesn't need to exist a result
  // for the API graph path that we want to add to our modeling (the path to the new
  // subclass). As an example, the following query has no results when evaluated against
  // a django/django DB.
  //
  // select API::moduleImport("django") .getMember("contrib") .getMember("admin")
  //       .getMember("views") .getMember("main") .getMember("ChangeListSearchForm")
  //
  //
  // Since it is a Form subclass that we would want to capture for our Django modeling,
  // we want to extend our modeling (that is written in a qll file) with exactly that
  // piece of code, but since the API::Node doesn't exist, we can't select that from a
  // predicate and print its path. We need a different approach, and for that we use
  // fully qualified names to capture new classes/new aliases, and transform these into
  // API paths (to be included in the modeling that is inserted into the `.qll` files),
  // see `fullyQualifiedToAPIGraphPath`.
  //
  // NOTE: this implementation was originally created to help with automatically
  // modeling packages in mind, and has been adjusted to help with manual library
  // modeling. See https://github.com/github/codeql/pull/5632 for more discussion.
  //
  //
  bindingset[fullyQualified]
  string fullyQualifiedToApiGraphPath(string fullyQualified) {
    result = "moduleImport(\"" + fullyQualified.replaceAll(".", "\").getMember(\"") + "\")"
  }

  bindingset[this]
  abstract class FindSubclassesSpec extends string {
    /**
     * Gets an API node for a class that has already been modeled. You can include
     * `.getASubclass*()` without causing problems, but it is not needed.
     */
    abstract API::Node getAlreadyModeledClass();

    FindSubclassesSpec getSuperClass() { none() }
  }

  /**
   * Holds if `newModelFullyQualified` describes either a new subclass, or a new alias, belonging to `spec` that we should include in our automated modeling.
   * This new element is defined by `ast`, which is defined at `loc` in the module `mod`.
   */
  predicate newModel(
    FindSubclassesSpec spec, string newModelFullyQualified, AstNode ast, Module mod, Location loc
  ) {
    (
      newSubclass(spec, newModelFullyQualified, ast, mod, loc)
      or
      newDirectAlias(spec, newModelFullyQualified, ast, mod, loc)
      or
      newImportAlias(spec, newModelFullyQualified, mod, _, _, loc) and
      ast = mod
    )
  }

  API::Node newOrExistingModeling(FindSubclassesSpec spec) {
    result = spec.getAlreadyModeledClass()
    or
    exists(string newSubclassName |
      newModel(spec, newSubclassName, _, _, _) and
      result.getPath() = fullyQualifiedToApiGraphPath(newSubclassName)
    )
  }

  /**
   * Holds if `fullyQualifiedName` is already explicitly modeled in the `spec`.
   *
   * For specs that do `.getASubclass*()`, items found by following a `.getASubclass`
   * edge will not be considered explicitly modeled.
   */
  bindingset[fullyQualifiedName]
  predicate alreadyExplicitlyModeled(FindSubclassesSpec spec, string fullyQualifiedName) {
    fullyQualifiedToApiGraphPath(fullyQualifiedName) = spec.getAlreadyModeledClass().getPath()
  }

  predicate isAllowedModule(Module mod) {
    // don't include anything found in site-packages
    exists(mod.getFile().getRelativePath()) and
    not mod.getFile().getRelativePath().regexpMatch("(?i)((^|/)examples?|^docs)/.*") and
    // to counter things like `my-example/app/foo.py` being allowed under `app.foo`
    forall(string part | part = mod.getFile().getParent().getRelativePath().splitAt("/") |
      legalShortName(part)
    )
  }

  predicate isTestCode(AstNode ast) {
    ast.getScope*() instanceof TestScope
    or
    ast.getLocation().getFile().getRelativePath().matches("tests/%")
  }

  predicate hasAllStatement(Module mod) {
    exists(AssignStmt a, GlobalVariable all |
      a.defines(all) and
      a.getScope() = mod and
      all.getId() = "__all__"
    )
  }

  /**
   * Holds if `newAliasFullyQualified` describes new alias originating from the import
   * `from <module> import <member> [as <new-name>]`, where `<module>.<member>` belongs to
   * `spec`.
   * So if this import happened in module `foo.bar`, `newAliasFullyQualified` would be
   * `foo.bar.<member>` (or `foo.bar.<new-name>`).
   *
   * Note that this predicate currently respects `__all__` in sort of a backwards fashion.
   * - if `__all__` is defined in module `foo.bar`, we only allow new aliases where the member name is also in `__all__`. (this doesn't map 100% to the semantics of imports though)
   * - If `__all__` is not defined we don't impose any limitations.
   *
   * Also note that we don't currently consider deleting module-attributes at all, so in the code snippet below, we would consider that `my_module.foo` is a
   * reference to `django.foo`, although `my_module.foo` isn't even available at runtime. (there currently also isn't any code to discover that `my_module.bar`
   * is an alias to `django.foo`)
   * ```py
   * # module my_module
   * from django import foo
   * bar = foo
   * del foo
   * ```
   */
  predicate newDirectAlias(
    FindSubclassesSpec spec, string newAliasFullyQualified, Expr value, Module mod, Location loc
  ) {
    exists(Alias alias | value = alias.getValue() |
      value = newOrExistingModeling(spec).getASubclass*().getAValueReachableFromSource().asExpr() and
      value.getScope() = mod and
      loc = value.getLocation() and
      exists(string base |
        mod.isPackageInit() and base = mod.getPackageName()
        or
        not mod.isPackageInit() and base = mod.getName()
      |
        newAliasFullyQualified = base + "." + alias.getAsname().(Name).getId()
      ) and
      (
        not hasAllStatement(mod)
        or
        mod.declaredInAll(alias.getAsname().(Name).getId())
      ) and
      not alreadyExplicitlyModeled(spec, newAliasFullyQualified) and
      not isTestCode(value) and
      isAllowedModule(mod)
    )
  }

  /**
   * same as `newDirectAlias` predicate, but written in a generic way to handle any import (also import *).
   *
   * it might be safe to delete `newDirectAlias` with this in place, but have not done the testing yet.
   */
  predicate newImportAlias(
    FindSubclassesSpec spec, string newAliasFullyQualified, Module mod, DataFlow::Node def,
    string relevantName, Location loc
  ) {
    loc = mod.getLocation() and
    exists(API::Node relevantClass, ControlFlowNode value |
      relevantClass = newOrExistingModeling(spec).getASubclass*() and
      ImportResolution::module_export(mod, relevantName, def) and
      value = relevantClass.getAValueReachableFromSource().asCfgNode() and
      (
        value = def.asVar().getDefinition().(AssignmentDefinition).getValue()
        or
        value = def.asCfgNode()
      )
      // value could be a ClassExpr if a new class is defined, or a Name if defining an alias
    ) and
    (
      mod.isPackageInit() and
      newAliasFullyQualified = mod.getPackageName() + "." + relevantName
      or
      not mod.isPackageInit() and
      newAliasFullyQualified = mod.getName() + "." + relevantName
    ) and
    (
      not hasAllStatement(mod)
      or
      mod.declaredInAll(relevantName)
    ) and
    not alreadyExplicitlyModeled(spec, newAliasFullyQualified) and
    not isTestCode(mod) and
    isAllowedModule(mod)
  }

  /** Holds if `classExpr` defines a new subclass that belongs to `spec`, which has the fully qualified name `newSubclassQualified`. */
  predicate newSubclass(
    FindSubclassesSpec spec, string newSubclassQualified, ClassExpr classExpr, Module mod,
    Location loc
  ) {
    classExpr = newOrExistingModeling(spec).getASubclass*().asSource().asExpr() and
    classExpr.getScope() = mod and
    newSubclassQualified = mod.getName() + "." + classExpr.getName() and
    loc = classExpr.getLocation() and
    not alreadyExplicitlyModeled(spec, newSubclassQualified) and
    not isTestCode(classExpr) and
    isAllowedModule(mod)
  }
}
