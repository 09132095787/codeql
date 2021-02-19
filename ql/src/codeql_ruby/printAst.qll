/**
 * Provides queries to pretty-print a Ruby abstract syntax tree as a graph.
 *
 * By default, this will print the AST for all nodes in the database. To change
 * this behavior, extend `PrintASTConfiguration` and override `shouldPrintNode`
 * to hold for only the AST nodes you wish to view.
 */

import AST

/**
 * The query can extend this class to control which nodes are printed.
 */
class PrintAstConfiguration extends string {
  PrintAstConfiguration() { this = "PrintAstConfiguration" }

  /**
   * Holds if the given node should be printed.
   */
  predicate shouldPrintNode(AstNode n) { any() }
}

/**
 * A node in the output tree.
 */
class PrintAstNode extends AstNode {
  string getProperty(string key) {
    key = "semmle.label" and
    result = "[" + this.getAPrimaryQlClass() + "] " + this.toString()
  }

  /**
   * Holds if this node should be printed in the output. By default, all nodes
   * are printed, but the query can override
   * `PrintAstConfiguration.shouldPrintNode` to filter the output.
   */
  predicate shouldPrint() { shouldPrintNode(this) }

  /**
   * Gets the child node that is accessed using the predicate `edgeName`.
   */
  PrintAstNode getChild(string edgeName) { range.child(edgeName, result) }
}

private predicate shouldPrintNode(AstNode n) {
  exists(PrintAstConfiguration config | config.shouldPrintNode(n))
}

/**
 * Holds if `node` belongs to the output tree, and its property `key` has the
 * given `value`.
 */
query predicate nodes(PrintAstNode node, string key, string value) {
  node.shouldPrint() and
  value = node.getProperty(key)
}

/**
 * Holds if `target` is a child of `source` in the AST, and property `key` of
 * the edge has the given `value`.
 */
query predicate edges(PrintAstNode source, PrintAstNode target, string key, string value) {
  source.shouldPrint() and
  target.shouldPrint() and
  key = "semmle.label" and
  source.getChild(value) = target
}

/**
 * Holds if property `key` of the graph has the given `value`.
 */
query predicate graphProperties(string key, string value) {
  key = "semmle.graphKind" and value = "tree"
}
