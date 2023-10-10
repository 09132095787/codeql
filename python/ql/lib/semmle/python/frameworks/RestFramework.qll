/**
 * Provides classes modeling security-relevant aspects of the `djangorestframework` PyPI package
 * (imported as `rest_framework`)
 *
 * See
 * - https://www.django-rest-framework.org/
 * - https://pypi.org/project/djangorestframework/
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.dataflow.new.RemoteFlowSources
private import semmle.python.dataflow.new.TaintTracking
private import semmle.python.Concepts
private import semmle.python.ApiGraphs
private import semmle.python.frameworks.internal.InstanceTaintStepsHelper
private import semmle.python.frameworks.Django
private import semmle.python.frameworks.Stdlib
private import semmle.python.frameworks.data.ModelsAsData

/**
 * INTERNAL: Do not use.
 *
 * Provides models for the `djangorestframework` PyPI package
 * (imported as `rest_framework`)
 *
 * See
 * - https://www.django-rest-framework.org/
 * - https://pypi.org/project/djangorestframework/
 */
module RestFramework {
  // ---------------------------------------------------------------------------
  // rest_framework.views.APIView handling
  // ---------------------------------------------------------------------------
  /**
   * An `API::Node` representing the `rest_framework.views.APIView` class or any subclass
   * that has explicitly been modeled in the CodeQL libraries.
   */
  private class ModeledApiViewClasses extends Django::Views::View::ModeledSubclass {
    ModeledApiViewClasses() {
      this = API::moduleImport("rest_framework").getMember("views").getMember("APIView")
      or
      // imports generated by python/frameworks/internal/SubclassFinder.qll
      this =
        API::moduleImport("rest_framework")
            .getMember("authtoken")
            .getMember("views")
            .getMember("APIView")
      or
      this =
        API::moduleImport("rest_framework")
            .getMember("authtoken")
            .getMember("views")
            .getMember("ObtainAuthToken")
      or
      this = API::moduleImport("rest_framework").getMember("decorators").getMember("APIView")
      or
      this = API::moduleImport("rest_framework").getMember("generics").getMember("CreateAPIView")
      or
      this = API::moduleImport("rest_framework").getMember("generics").getMember("DestroyAPIView")
      or
      this = API::moduleImport("rest_framework").getMember("generics").getMember("GenericAPIView")
      or
      this = API::moduleImport("rest_framework").getMember("generics").getMember("ListAPIView")
      or
      this =
        API::moduleImport("rest_framework").getMember("generics").getMember("ListCreateAPIView")
      or
      this = API::moduleImport("rest_framework").getMember("generics").getMember("RetrieveAPIView")
      or
      this =
        API::moduleImport("rest_framework")
            .getMember("generics")
            .getMember("RetrieveDestroyAPIView")
      or
      this =
        API::moduleImport("rest_framework").getMember("generics").getMember("RetrieveUpdateAPIView")
      or
      this =
        API::moduleImport("rest_framework")
            .getMember("generics")
            .getMember("RetrieveUpdateDestroyAPIView")
      or
      this = API::moduleImport("rest_framework").getMember("generics").getMember("UpdateAPIView")
      or
      this = API::moduleImport("rest_framework").getMember("routers").getMember("APIRootView")
      or
      this = API::moduleImport("rest_framework").getMember("routers").getMember("SchemaView")
      or
      this =
        API::moduleImport("rest_framework")
            .getMember("schemas")
            .getMember("views")
            .getMember("APIView")
      or
      this =
        API::moduleImport("rest_framework")
            .getMember("schemas")
            .getMember("views")
            .getMember("SchemaView")
      or
      this = API::moduleImport("rest_framework").getMember("viewsets").getMember("GenericViewSet")
      or
      this = API::moduleImport("rest_framework").getMember("viewsets").getMember("ModelViewSet")
      or
      this =
        API::moduleImport("rest_framework").getMember("viewsets").getMember("ReadOnlyModelViewSet")
      or
      this = API::moduleImport("rest_framework").getMember("viewsets").getMember("ViewSet")
    }
  }

  /**
   * A class that has a super-type which is a rest_framework APIView class, therefore also
   * becoming a APIView class.
   */
  class RestFrameworkApiViewClass extends PrivateDjango::DjangoViewClassFromSuperClass {
    RestFrameworkApiViewClass() {
      this.getParent() = any(ModeledApiViewClasses c).getASubclass*().asSource().asExpr()
    }

    override Function getARequestHandler() {
      result = super.getARequestHandler()
      or
      // TODO: This doesn't handle attribute assignment. Should be OK, but analysis is not as complete as with
      // points-to and `.lookup`, which would handle `post = my_post_handler` inside class def
      result = this.getAMethod() and
      result.getName() in [
          // these method names where found by looking through the APIView
          // implementation in
          // https://github.com/encode/django-rest-framework/blob/master/rest_framework/views.py#L104
          "initial", "http_method_not_allowed", "permission_denied", "throttled",
          "get_authenticate_header", "perform_content_negotiation", "perform_authentication",
          "check_permissions", "check_object_permissions", "check_throttles", "determine_version",
          "initialize_request", "finalize_response", "dispatch", "options",
          // ModelViewSet
          // https://github.com/encode/django-rest-framework/blob/master/rest_framework/viewsets.py
          "create", "retrieve", "update", "partial_update", "destroy", "list"
        ]
    }
  }

  // ---------------------------------------------------------------------------
  // rest_framework.decorators.api_view handling
  // ---------------------------------------------------------------------------
  /**
   * A function that is a request handler since it is decorated with `rest_framework.decorators.api_view`
   */
  class RestFrameworkFunctionBasedView extends PrivateDjango::DjangoRouteHandler::Range {
    RestFrameworkFunctionBasedView() {
      this.getADecorator() =
        API::moduleImport("rest_framework")
            .getMember("decorators")
            .getMember("api_view")
            .getACall()
            .asExpr()
    }
  }

  /**
   * Ensuring that all `RestFrameworkFunctionBasedView` are also marked as a
   * `HTTP::Server::RequestHandler`. We only need this for the ones that doesn't have a
   * known route setup.
   */
  class RestFrameworkFunctionBasedViewWithoutKnownRoute extends Http::Server::RequestHandler::Range,
    PrivateDjango::DjangoRouteHandler instanceof RestFrameworkFunctionBasedView
  {
    RestFrameworkFunctionBasedViewWithoutKnownRoute() {
      not exists(PrivateDjango::DjangoRouteSetup setup | setup.getARequestHandler() = this)
    }

    override Parameter getARoutedParameter() {
      // Since we don't know the URL pattern, we simply mark all parameters as a routed
      // parameter. This should give us more RemoteFlowSources but could also lead to
      // more FPs. If this turns out to be the wrong tradeoff, we can always change our mind.
      result in [this.getArg(_), this.getArgByName(_)] and
      not result = any(int i | i < this.getFirstPossibleRoutedParamIndex() | this.getArg(i))
    }

    override string getFramework() { result = "Django (rest_framework)" }
  }

  // ---------------------------------------------------------------------------
  // request modeling
  // ---------------------------------------------------------------------------
  /**
   * A parameter that will receive a `rest_framework.request.Request` instance when a
   * request handler is invoked.
   */
  private class RestFrameworkRequestHandlerRequestParam extends Request::InstanceSource,
    RemoteFlowSource::Range, DataFlow::ParameterNode
  {
    RestFrameworkRequestHandlerRequestParam() {
      // rest_framework.views.APIView subclass
      exists(RestFrameworkApiViewClass vc |
        this.getParameter() =
          vc.getARequestHandler().(PrivateDjango::DjangoRouteHandler).getRequestParam()
      )
      or
      // annotated with @api_view decorator
      exists(PrivateDjango::DjangoRouteHandler rh | rh instanceof RestFrameworkFunctionBasedView |
        this.getParameter() = rh.getRequestParam()
      )
    }

    override string getSourceType() { result = "rest_framework.request.HttpRequest" }
  }

  /**
   * Provides models for the `rest_framework.request.Request` class
   *
   * See https://www.django-rest-framework.org/api-guide/requests/.
   */
  module Request {
    /** Gets a reference to the `rest_framework.request.Request` class. */
    API::Node classRef() {
      result = API::moduleImport("rest_framework").getMember("request").getMember("Request")
      or
      result = ModelOutput::getATypeNode("rest_framework.request.Request~Subclass").getASubclass*()
    }

    /**
     * A source of instances of `rest_framework.request.Request`, extend this class to model new instances.
     *
     * This can include instantiations of the class, return values from function
     * calls, or a special parameter that will be set when functions are called by an external
     * library.
     *
     * Use the predicate `Request::instance()` to get references to instances of `rest_framework.request.Request`.
     */
    abstract class InstanceSource extends PrivateDjango::DjangoImpl::DjangoHttp::Request::HttpRequest::InstanceSource
    { }

    /** A direct instantiation of `rest_framework.request.Request`. */
    private class ClassInstantiation extends InstanceSource, DataFlow::CallCfgNode {
      ClassInstantiation() { this = classRef().getACall() }
    }

    /** Gets a reference to an instance of `rest_framework.request.Request`. */
    private DataFlow::TypeTrackingNode instance(DataFlow::TypeTracker t) {
      t.start() and
      result instanceof InstanceSource
      or
      exists(DataFlow::TypeTracker t2 | result = instance(t2).track(t2, t))
    }

    /** Gets a reference to an instance of `rest_framework.request.Request`. */
    DataFlow::Node instance() { instance(DataFlow::TypeTracker::end()).flowsTo(result) }

    /**
     * Taint propagation for `rest_framework.request.Request`.
     */
    private class InstanceTaintSteps extends InstanceTaintStepsHelper {
      InstanceTaintSteps() { this = "rest_framework.request.Request" }

      override DataFlow::Node getInstance() { result = instance() }

      override string getAttributeName() {
        result in ["data", "query_params", "user", "auth", "content_type", "stream"]
      }

      override string getMethodName() { none() }

      override string getAsyncMethodName() { none() }
    }

    /** An attribute read that is a `MultiValueDict` instance. */
    private class MultiValueDictInstances extends Django::MultiValueDict::InstanceSource {
      MultiValueDictInstances() {
        this.(DataFlow::AttrRead).getObject() = instance() and
        this.(DataFlow::AttrRead).getAttributeName() = "query_params"
      }
    }

    /** An attribute read that is a `User` instance. */
    private class UserInstances extends Django::User::InstanceSource {
      UserInstances() {
        this.(DataFlow::AttrRead).getObject() = instance() and
        this.(DataFlow::AttrRead).getAttributeName() = "user"
      }
    }

    /** An attribute read that is a file-like instance. */
    private class FileLikeInstances extends Stdlib::FileLikeObject::InstanceSource {
      FileLikeInstances() {
        this.(DataFlow::AttrRead).getObject() = instance() and
        this.(DataFlow::AttrRead).getAttributeName() = "stream"
      }
    }
  }

  // ---------------------------------------------------------------------------
  // response modeling
  // ---------------------------------------------------------------------------
  /**
   * Provides models for the `rest_framework.response.Response` class
   *
   * See https://www.django-rest-framework.org/api-guide/responses/.
   */
  module Response {
    /** Gets a reference to the `rest_framework.response.Response` class. */
    API::Node classRef() {
      result = API::moduleImport("rest_framework").getMember("response").getMember("Response")
      or
      result =
        ModelOutput::getATypeNode("rest_framework.response.Response~Subclass").getASubclass*()
    }

    /** A direct instantiation of `rest_framework.response.Response`. */
    private class ClassInstantiation extends PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponse::InstanceSource,
      DataFlow::CallCfgNode
    {
      ClassInstantiation() { this = classRef().getACall() }

      override DataFlow::Node getBody() { result in [this.getArg(0), this.getArgByName("data")] }

      override DataFlow::Node getMimetypeOrContentTypeArg() {
        result in [this.getArg(5), this.getArgByName("content_type")]
      }

      override string getMimetypeDefault() { none() }
    }
  }

  // ---------------------------------------------------------------------------
  // Exception response modeling
  // ---------------------------------------------------------------------------
  /**
   * Provides models for the `rest_framework.exceptions.APIException` class and subclasses
   *
   * See https://www.django-rest-framework.org/api-guide/exceptions/#api-reference
   */
  module ApiException {
    /** A direct instantiation of `rest_framework.exceptions.ApiException` or subclass. */
    private class ClassInstantiation extends Http::Server::HttpResponse::Range,
      DataFlow::CallCfgNode
    {
      string className;

      ClassInstantiation() {
        className in [
            "APIException", "ValidationError", "ParseError", "AuthenticationFailed",
            "NotAuthenticated", "PermissionDenied", "NotFound", "MethodNotAllowed", "NotAcceptable",
            "UnsupportedMediaType", "Throttled"
          ] and
        this =
          API::moduleImport("rest_framework")
              .getMember("exceptions")
              .getMember(className)
              .getACall()
      }

      override DataFlow::Node getBody() {
        className in [
            "APIException", "ValidationError", "ParseError", "AuthenticationFailed",
            "NotAuthenticated", "PermissionDenied", "NotFound", "NotAcceptable"
          ] and
        result = this.getArg(0)
        or
        className in ["MethodNotAllowed", "UnsupportedMediaType", "Throttled"] and
        result = this.getArg(1)
        or
        result = this.getArgByName("detail")
      }

      override DataFlow::Node getMimetypeOrContentTypeArg() { none() }

      override string getMimetypeDefault() { none() }
    }
  }
}
