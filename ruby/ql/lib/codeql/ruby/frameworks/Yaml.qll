/**
 * Provides modeling for the `YAML` and `Psych` libraries.
 */

private import codeql.ruby.dataflow.FlowSteps
private import codeql.ruby.DataFlow
private import codeql.ruby.ApiGraphs

/**
 * A taint step related to the result of `YAML.parse` calls, or similar.
 *In the following example, this step will propagate taint from
 *`source` to `sink`:
 *
 *```rb
 *x = source
 *result = YAML.parse(x)
 *sink result.to_ruby # Unsafe call
 * ```
 */
private class YamlParseStep extends AdditionalTaintStep {
  override predicate step(DataFlow::Node pred, DataFlow::Node succ) {
    exists(DataFlow::CallNode yamlParserMethod |
      yamlParserMethod = yamlNode().getAMethodCall(["parse", "parse_stream"]) and
      (
        pred = yamlParserMethod.getArgument(0) or
        pred = yamlParserMethod.getKeywordArgument("yaml")
      ) and
      succ = yamlParserMethod.getAMethodCall("to_ruby")
      or
      yamlParserMethod = yamlNode().getAMethodCall("parse_file") and
      (
        pred = yamlParserMethod.getArgument(0) or
        pred = yamlParserMethod.getKeywordArgument("filename")
      ) and
      succ = yamlParserMethod.getAMethodCall("to_ruby")
    )
  }
}

/**
 * YAML/Psych Top level Class member
 */
private API::Node yamlNode() { result = API::getTopLevelMember(["YAML", "Psych"]) }
