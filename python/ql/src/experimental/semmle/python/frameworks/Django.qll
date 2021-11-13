/**
 * Provides classes modeling security-relevant aspects of the `django` PyPI package.
 * See https://www.djangoproject.com/.
 */

private import python
private import semmle.python.frameworks.Django
private import semmle.python.dataflow.new.DataFlow
private import experimental.semmle.python.Concepts
private import semmle.python.ApiGraphs
private import semmle.python.dataflow.new.RemoteFlowSources

private module PrivateDjango {
  private module django {
    API::Node http() { result = API::moduleImport("django").getMember("http") }

    module http {
      API::Node response() { result = http().getMember("response") }

      API::Node request() { result = http().getMember("request") }

      module request {
        module HttpRequest {
          class DjangoGETParameter extends DataFlow::Node, RemoteFlowSource::Range {
            DjangoGETParameter() { this = request().getMember("GET").getMember("get").getACall() }

            override string getSourceType() { result = "django.http.request.GET.get" }
          }
        }
      }

      module response {
        module HttpResponse {
          API::Node baseClassRef() {
            result = response().getMember("HttpResponse").getReturn()
            or
            // Handle `django.http.HttpResponse` alias
            result = http().getMember("HttpResponse").getReturn()
          }

          /** Gets a reference to a header instance. */
          private DataFlow::LocalSourceNode headerInstance(DataFlow::TypeTracker t) {
            t.start() and
            (
              exists(SubscriptNode subscript |
                subscript.getObject() = baseClassRef().getAUse().asCfgNode() and
                result.asCfgNode() = subscript
              )
              or
              result.(DataFlow::AttrRead).getObject() = baseClassRef().getAUse()
            )
            or
            exists(DataFlow::TypeTracker t2 | result = headerInstance(t2).track(t2, t))
          }

          /** Gets a reference to a header instance use. */
          private DataFlow::Node headerInstance() {
            headerInstance(DataFlow::TypeTracker::end()).flowsTo(result)
          }

          /** Gets a reference to a header instance call with `__setitem__`. */
          private DataFlow::Node headerSetItemCall() {
            result = headerInstance() and
            result.(DataFlow::AttrRead).getAttributeName() = "__setitem__"
          }

          class DjangoResponseSetItemCall extends DataFlow::CallCfgNode, HeaderDeclaration::Range {
            DjangoResponseSetItemCall() { this.getFunction() = headerSetItemCall() }

            override DataFlow::Node getNameArg() { result = this.getArg(0) }

            override DataFlow::Node getValueArg() { result = this.getArg(1) }
          }

          class DjangoResponseDefinition extends DataFlow::Node, HeaderDeclaration::Range {
            DataFlow::Node headerInput;

            DjangoResponseDefinition() {
              this.asCfgNode().(DefinitionNode) = headerInstance().asCfgNode() and
              headerInput.asCfgNode() = this.asCfgNode().(DefinitionNode).getValue()
            }

            override DataFlow::Node getNameArg() {
              result.asExpr() = this.asExpr().(Subscript).getIndex()
            }

            override DataFlow::Node getValueArg() { result = headerInput }
          }
        }
      }
    }

    module email {
      /** https://docs.djangoproject.com/en/3.2/topics/email/ */
      private API::Node djangoMail() {
        result = API::moduleImport("django").getMember("core").getMember("mail")
      }

      /**
       * Gets a call to `django.core.mail.send_mail()`.
       *
       * Given the following example:
       *
       * ```py
       * send_mail("Subject", "plain-text body", "from@example.com", ["to@example.com"], html_message=django.http.request.GET.get("html"))
       * ```
       *
       * * `this` would be `send_mail("Subject", "plain-text body", "from@example.com", ["to@example.com"], html_message=django.http.request.GET.get("html"))`.
       * * `getPlainTextBody()`'s result would be `"plain-text body"`.
       * * `getHtmlBody()`'s result would be `django.http.request.GET.get("html")`.
       * * `getTo()`'s result would be `["to@example.com"]`.
       * * `getFrom()`'s result would be `"from@example.com"`.
       * * `getSubject()`'s result would be `"Subject"`.
       */
      private class DjangoSendMail extends DataFlow::CallCfgNode, EmailSender::Range {
        DjangoSendMail() { this = djangoMail().getMember("send_mail").getACall() }

        override DataFlow::Node getPlainTextBody() {
          result in [this.getArg(1), this.getArgByName("message")]
        }

        override DataFlow::Node getHtmlBody() {
          result in [this.getArg(8), this.getArgByName("html_message")]
        }

        override DataFlow::Node getTo() {
          result in [this.getArg(3), this.getArgByName("recipient_list")]
        }

        override DataFlow::Node getFrom() {
          result in [this.getArg(2), this.getArgByName("from_email")]
        }

        override DataFlow::Node getSubject() {
          result in [this.getArg(0), this.getArgByName("subject")]
        }
      }

      /**
       * Gets a call to `django.core.mail.mail_admins()` or `django.core.mail.mail_managers()`.
       *
       * Given the following example:
       *
       * ```py
       * mail_admins("Subject", "plain-text body", html_message=django.http.request.GET.get("html"))
       * ```
       *
       * * `this` would be `mail_admins("Subject", "plain-text body", html_message=django.http.request.GET.get("html"))`.
       * * `getPlainTextBody()`'s result would be `"plain-text body"`.
       * * `getHtmlBody()`'s result would be `django.http.request.GET.get("html")`.
       * * `getTo()`'s result would be `none`.
       * * `getFrom()`'s result would be `none`.
       * * `getSubject()`'s result would be `"Subject"`.
       */
      private class DjangoMailInternal extends DataFlow::CallCfgNode, EmailSender::Range {
        DjangoMailInternal() {
          this = djangoMail().getMember(["mail_admins", "mail_managers"]).getACall()
        }

        override DataFlow::Node getPlainTextBody() {
          result in [this.getArg(1), this.getArgByName("message")]
        }

        override DataFlow::Node getHtmlBody() {
          result in [this.getArg(4), this.getArgByName("html_message")]
        }

        override DataFlow::Node getTo() { none() }

        override DataFlow::Node getFrom() { none() }

        override DataFlow::Node getSubject() {
          result in [this.getArg(0), this.getArgByName("subject")]
        }
      }
    }
  }
}
