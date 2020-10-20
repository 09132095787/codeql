/**
 * Provides classes and predicates used by the XSS queries.
 */

import go

/**
 * Provides extension points for customizing the taint-tracking configuration for reasoning about
 * reflected cross-site scripting vulnerabilities.
 */
module ReflectedXss {
  /** A data flow source for reflected XSS vulnerabilities. */
  abstract class Source extends DataFlow::Node { }

  /** A data flow sink for reflected XSS vulnerabilities. */
  abstract class Sink extends DataFlow::Node {
    /**
     * Gets the kind of vulnerability to report in the alert message.
     *
     * Defaults to `Cross-site scripting`, but may be overriden for sinks
     * that do not allow script injection, but injection of other undesirable HTML elements.
     */
    string getVulnerabilityKind() { result = "Cross-site scripting" }
  }

  /** A sanitizer for reflected XSS vulnerabilities. */
  abstract class Sanitizer extends DataFlow::Node { }

  /**
   * A sanitizer guard for reflected XSS vulnerabilities.
   */
  abstract class SanitizerGuard extends DataFlow::BarrierGuard { }

  /**
   * An expression that is sent as part of an HTTP response body, considered as an
   * XSS sink.
   *
   * We exclude cases where the route handler sets either an unknown content type or
   * a content type that does not (case-insensitively) contain the string "html". This
   * is to prevent us from flagging plain-text or JSON responses as vulnerable.
   */
  class HttpResponseBodySink extends Sink, HTTP::ResponseBody {
    HttpResponseBodySink() { not nonHtmlContentType(this) }
  }

  /**
   * Holds if `body` specifies the response's content type to be HTML.
   */
  private predicate htmlTypeSpecified(HTTP::ResponseBody body) {
    body.getAContentType().regexpMatch("(?i).*html.*")
  }

  /**
   * Holds if `body` may send a response with a content type other than HTML.
   */
  private predicate nonHtmlContentType(HTTP::ResponseBody body) {
    not htmlTypeSpecified(body) and
    (
      exists(body.getAContentType())
      or
      exists(body.getAContentTypeNode())
      or
      exists(DataFlow::CallNode call | call.getTarget().hasQualifiedName("fmt", "Fprintf") |
        body = call.getAnArgument() and
        // checks that the format value does not start with (ignoring whitespace as defined by
        // https://mimesniff.spec.whatwg.org/#whitespace-byte):
        //  - '<', which could lead to an HTML content type being detected, or
        //  - '%', which could be a format string.
        call.getArgument(1).getStringValue().regexpMatch("(?s)[\\t\\n\\x0c\\r ]*+[^<%].*")
      )
      or
      exists(DataFlow::Node pred | body = pred.getASuccessor*() |
        // data starting with a character other than `<` (ignoring whitespace as defined by
        // https://mimesniff.spec.whatwg.org/#whitespace-byte) cannot cause an HTML content type to
        // be detected.
        pred.getStringValue().regexpMatch("(?s)[\\t\\n\\x0c\\r ]*+[^<].*")
      )
    )
  }

  /**
   * A third-party controllable input, considered as a flow source for reflected XSS.
   */
  class UntrustedFlowAsSource extends Source, UntrustedFlowSource { }

  /**
   * A regexp replacement involving an HTML meta-character, or a call to an escape
   * function, viewed as a sanitizer for XSS vulnerabilities.
   *
   * The XSS queries do not attempt to reason about correctness or completeness of sanitizers,
   * so any such call stops taint propagation.
   */
  class MetacharEscapeSanitizer extends Sanitizer, DataFlow::CallNode {
    MetacharEscapeSanitizer() {
      exists(Function f | f = this.getCall().getTarget() |
        f.(RegexpReplaceFunction).getRegexp(this).getPattern().regexpMatch(".*['\"&<>].*")
        or
        f instanceof HtmlEscapeFunction
        or
        f instanceof JsEscapeFunction
      )
    }
  }

  /**
   * A check against a constant value, considered a barrier for reflected XSS.
   */
  class EqualityTestGuard extends SanitizerGuard, DataFlow::EqualityTestNode {
    override predicate checks(Expr e, boolean outcome) {
      this.getAnOperand().isConst() and
      e = this.getAnOperand().asExpr() and
      outcome = this.getPolarity()
    }
  }

  /**
   * A JSON marshaler, acting to sanitize a possible XSS vulnerability because the
   * marshaled value is very unlikely to be returned as an HTML content-type.
   */
  class JsonMarshalSanitizer extends Sanitizer {
    JsonMarshalSanitizer() {
      exists(MarshalingFunction mf | mf.getFormat() = "JSON" |
        this = mf.getOutput().getNode(mf.getACall())
      )
    }
  }
}
