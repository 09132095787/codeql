/**
 * Provides classes modeling security-relevant aspects of the `flask` PyPI package.
 * See https://flask.palletsprojects.com/en/1.1.x/.
 */

private import python
private import semmle.python.frameworks.Flask
private import semmle.python.dataflow.new.DataFlow
private import experimental.semmle.python.Concepts
private import semmle.python.ApiGraphs

module ExperimentalFlask {
  /**
   * A reference to either `flask.make_response` function, or the `make_response` method on
   * an instance of `flask.Flask`. This creates an instance of the `flask_response`
   * class (class-attribute on a flask application), which by default is
   * `flask.Response`.
   *
   * See
   * - https://flask.palletsprojects.com/en/1.1.x/api/#flask.Flask.make_response
   * - https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response
   */
  private API::Node flaskMakeResponse() {
    result in [
        API::moduleImport("flask").getMember("make_response"),
        Flask::FlaskApp::instance().getMember("make_response")
      ]
  }

  /** Gets a reference to a header instance. */
  private DataFlow::LocalSourceNode headerInstance(DataFlow::TypeTracker t) {
    t.start() and
    result.(DataFlow::AttrRead).getObject().getALocalSource() =
      [Flask::Response::classRef(), flaskMakeResponse()].getReturn().getAUse()
    or
    exists(DataFlow::TypeTracker t2 | result = headerInstance(t2).track(t2, t))
  }

  /** Gets a reference to a header instance use. */
  private DataFlow::Node headerInstance() {
    headerInstance(DataFlow::TypeTracker::end()).flowsTo(result)
  }

  /** Gets a reference to a header instance call/subscript */
  private DataFlow::Node headerInstanceCall() {
    headerInstance() in [result.(DataFlow::AttrRead), result.(DataFlow::AttrRead).getObject()] or
    headerInstance().asExpr() = result.asExpr().(Subscript).getObject()
  }

  class FlaskHeaderDefinition extends DataFlow::Node, HeaderDeclaration::Range {
    DataFlow::Node headerInput;

    FlaskHeaderDefinition() {
      this.asCfgNode().(DefinitionNode) = headerInstanceCall().asCfgNode() and
      headerInput.asCfgNode() = this.asCfgNode().(DefinitionNode).getValue()
    }

    override DataFlow::Node getHeaderInput() {
      result.asExpr() in [headerInput.asExpr(), this.asExpr().(Subscript).getIndex()]
    }
  }

  private class FlaskMakeResponseExtend extends DataFlow::CallCfgNode, HeaderDeclaration::Range {
    FlaskMakeResponseExtend() { this.getFunction() = headerInstanceCall() }

    override DataFlow::Node getHeaderInput() { result = this.getArg(0) }
  }

  private class FlaskResponse extends DataFlow::CallCfgNode, HeaderDeclaration::Range {
    FlaskResponse() { this = Flask::Response::classRef().getACall() }

    override DataFlow::Node getHeaderInput() { result = this.getArgByName("headers") }
  }
}
