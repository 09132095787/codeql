/**
 * @name Find new subclasses to model
 * @id py/meta/find-subclasses-to-model
 * @kind table
 */

import python
import semmle.python.dataflow.new.DataFlow
private import semmle.python.ApiGraphs
import semmle.python.frameworks.internal.SubclassFinder::NotExposed
private import semmle.python.frameworks.Flask
private import semmle.python.frameworks.FastApi
private import semmle.python.frameworks.Django
private import semmle.python.frameworks.Tornado
private import semmle.python.frameworks.Stdlib
private import semmle.python.frameworks.Requests
private import semmle.python.frameworks.Starlette
private import semmle.python.frameworks.ClickhouseDriver
private import semmle.python.frameworks.Aiohttp
private import semmle.python.frameworks.Fabric
private import semmle.python.frameworks.Httpx
private import semmle.python.frameworks.Invoke
private import semmle.python.frameworks.MarkupSafe
private import semmle.python.frameworks.Multidict
private import semmle.python.frameworks.Pycurl
private import semmle.python.frameworks.RestFramework
import semmle.python.frameworks.data.internal.ApiGraphModelsExtensions as Extensions

class FlaskViewClasses extends FindSubclassesSpec {
  FlaskViewClasses() { this = "flask.View~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Flask::Views::View::subclassRef() }
}

class FlaskMethodViewClasses extends FindSubclassesSpec {
  FlaskMethodViewClasses() { this = "flask.MethodView~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Flask::Views::MethodView::subclassRef() }

  override FlaskViewClasses getSuperClass() { any() }
}

class FastApiRouter extends FindSubclassesSpec {
  FastApiRouter() { this = "fastapi.APIRouter~Subclass" }

  override API::Node getAlreadyModeledClass() { result = FastApi::ApiRouter::cls() }
}

class DjangoForms extends FindSubclassesSpec {
  DjangoForms() { this = "django.forms.BaseForm~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = any(Django::Forms::Form::ModeledSubclass subclass)
  }
}

class DjangoView extends FindSubclassesSpec {
  DjangoView() { this = "Django.Views.View~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = any(Django::Views::View::ModeledSubclass subclass)
  }
}

class DjangoField extends FindSubclassesSpec {
  DjangoField() { this = "Django.Forms.Field~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = any(Django::Forms::Field::ModeledSubclass subclass)
  }
}

class DjangoModel extends FindSubclassesSpec {
  DjangoModel() { this = "Django.db.models.Model~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DB::Models::Model::subclassRef()
  }
}

class TornadoRequestHandler extends FindSubclassesSpec {
  TornadoRequestHandler() { this = "tornado.web.RequestHandler~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = Tornado::TornadoModule::Web::RequestHandler::subclassRef()
  }
}

class WSGIServer extends FindSubclassesSpec {
  WSGIServer() { this = "wsgiref.simple_server.WSGIServer~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = StdlibPrivate::WsgirefSimpleServer::subclassRef()
  }
}

class StdlibBaseHttpRequestHandler extends FindSubclassesSpec {
  StdlibBaseHttpRequestHandler() { this = "http.server.BaseHTTPRequestHandler~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = StdlibPrivate::BaseHttpRequestHandler::subclassRef()
  }
}

class StdlibCgiFieldStorage extends FindSubclassesSpec {
  StdlibCgiFieldStorage() { this = "cgi.FieldStorage~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = StdlibPrivate::Cgi::FieldStorage::subclassRef()
  }
}

class DjangoHttpResponse extends FindSubclassesSpec {
  DjangoHttpResponse() { this = "django.http.response.HttpResponse~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponse::classRef()
  }
}

class DjangoHttpResponseRedirect extends FindSubclassesSpec {
  DjangoHttpResponseRedirect() { this = "django.http.response.HttpResponseRedirect~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseRedirect::classRef()
  }
}

class DjangoHttpResponsePermanentRedirect extends FindSubclassesSpec {
  DjangoHttpResponsePermanentRedirect() {
    this = "django.http.response.HttpResponsePermanentRedirect~Subclass"
  }

  override API::Node getAlreadyModeledClass() {
    result =
      PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponsePermanentRedirect::classRef()
  }
}

class DjangoHttpResponseNotModified extends FindSubclassesSpec {
  DjangoHttpResponseNotModified() { this = "django.http.response.HttpResponseNotModified~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseNotModified::classRef()
  }
}

class DjangoHttpResponseBadRequest extends FindSubclassesSpec {
  DjangoHttpResponseBadRequest() { this = "django.http.response.HttpResponseBadRequest~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseBadRequest::classRef()
  }
}

class DjangoHttpResponseNotFound extends FindSubclassesSpec {
  DjangoHttpResponseNotFound() { this = "django.http.response.HttpResponseNotFound~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseNotFound::classRef()
  }
}

class DjangoHttpResponseForbidden extends FindSubclassesSpec {
  DjangoHttpResponseForbidden() { this = "django.http.response.HttpResponseForbidden~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseForbidden::classRef()
  }
}

class DjangoHttpResponseNotAllowed extends FindSubclassesSpec {
  DjangoHttpResponseNotAllowed() { this = "django.http.response.HttpResponseNotAllowed~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseNotAllowed::classRef()
  }
}

class DjangoHttpResponseGone extends FindSubclassesSpec {
  DjangoHttpResponseGone() { this = "django.http.response.HttpResponseGone~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseGone::classRef()
  }
}

class DjangoHttpResponseServerError extends FindSubclassesSpec {
  DjangoHttpResponseServerError() { this = "django.http.response.HttpResponseServerError~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseServerError::classRef()
  }
}

class DjangoHttpResponseJsonResponse extends FindSubclassesSpec {
  DjangoHttpResponseJsonResponse() { this = "django.http.response.JsonResponse~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::JsonResponse::classRef()
  }
}

class DjangoHttpResponseStreamingResponse extends FindSubclassesSpec {
  DjangoHttpResponseStreamingResponse() {
    this = "django.http.response.StreamingHttpResponse~Subclass"
  }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::StreamingHttpResponse::classRef()
  }
}

class DjangoHttpResponseFileResponse extends FindSubclassesSpec {
  DjangoHttpResponseFileResponse() { this = "django.http.response.FileResponse~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::FileResponse::classRef()
  }
}

class FlaskResponse extends FindSubclassesSpec {
  FlaskResponse() { this = "flask.Response~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Flask::Response::classRef() }
}

class RequestsResponse extends FindSubclassesSpec {
  RequestsResponse() { this = "requests.models.Response~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Requests::Response::classRef() }
}

class HttpClientHttpResponse extends FindSubclassesSpec {
  HttpClientHttpResponse() { this = "http.client.HTTPResponse~Subclass" }

  override API::Node getAlreadyModeledClass() { result = StdlibPrivate::HttpResponse::classRef() }
}

class StarletteWebsocket extends FindSubclassesSpec {
  StarletteWebsocket() { this = "starlette.websockets.WebSocket~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Starlette::WebSocket::classRef() }
}

class ClickhouseClient extends FindSubclassesSpec {
  ClickhouseClient() { this = "clickhouse_driver.client.Client~Subclass" }

  override API::Node getAlreadyModeledClass() { result = ClickhouseDriver::Client::subclassRef() }
}

class AiohttpSession extends FindSubclassesSpec {
  AiohttpSession() { this = "aiohttp.ClientSession~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = AiohttpClientModel::ClientSession::classRef()
  }
}

class FabricConnection extends FindSubclassesSpec {
  FabricConnection() { this = "fabric.connection.Connection~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = FabricV2::Fabric::Connection::ConnectionClass::classRef()
  }
}

class DjangoRawSql extends FindSubclassesSpec {
  DjangoRawSql() { this = "django.db.models.expressions.RawSQL~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DB::Models::Expressions::RawSql::classRef()
  }
}

class DjangoHttpRequest extends FindSubclassesSpec {
  DjangoHttpRequest() { this = "django.http.request.HttpRequest~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Request::HttpRequest::classRef()
  }
}

class FlaskClass extends FindSubclassesSpec {
  FlaskClass() { this = "flask.Flask~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Flask::FlaskApp::classRef() }
}

class FlaskBlueprint extends FindSubclassesSpec {
  FlaskBlueprint() { this = "flask.Blueprint~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Flask::Blueprint::classRef() }
}

class HttpxClient extends FindSubclassesSpec {
  HttpxClient() { this = "httpx.Client~Subclass" }

  override API::Node getAlreadyModeledClass() { result = HttpxModel::Client::classRef() }
}

class InvokeContext extends FindSubclassesSpec {
  InvokeContext() { this = "invoke.context.Context~Subclass" }

  override API::Node getAlreadyModeledClass() {
    result = Invoke::InvokeModule::Context::ContextClass::classRef()
  }
}

class MarkupSafe extends FindSubclassesSpec {
  MarkupSafe() { this = "markupsafe.Markup~Subclass" }

  override API::Node getAlreadyModeledClass() { result = MarkupSafeModel::Markup::classRef() }
}

class Multidict extends FindSubclassesSpec {
  Multidict() { this = "multidict.MultiDictProxy~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Multidict::MultiDictProxy::classRef() }
}

class PyCurl extends FindSubclassesSpec {
  PyCurl() { this = "pycurl.Curl~Subclass" }

  override API::Node getAlreadyModeledClass() { result = Pycurl::Curl::classRef() }
}

class RestFrameworkRequest extends FindSubclassesSpec {
  RestFrameworkRequest() { this = "rest_framework.request.Request~Subclass" }

  override API::Node getAlreadyModeledClass() { result = RestFramework::Request::classRef() }
}

class RestFrameworkResponse extends FindSubclassesSpec {
  RestFrameworkResponse() { this = "rest_framework.response.Response~Subclass" }

  override API::Node getAlreadyModeledClass() { result = RestFramework::Response::classRef() }
}

bindingset[fullyQualified]
predicate fullyQualifiedToYamlFormat(string fullyQualified, string type2, string path) {
  exists(int firstDot | firstDot = fullyQualified.indexOf(".", 0, 0) |
    type2 = fullyQualified.prefix(firstDot) and
    path =
      ("Member[" + fullyQualified.suffix(firstDot + 1).replaceAll(".", "].Member[") + "]")
          .replaceAll(".Member[__init__].", "")
          .replaceAll("Member[__init__].", "")
  )
}

from FindSubclassesSpec spec, string newModelFullyQualified, string type2, string path, Module mod
where
  newModel(spec, newModelFullyQualified, _, mod, _) and
  not exists(FindSubclassesSpec subclass | subclass.getSuperClass() = spec |
    newModel(subclass, newModelFullyQualified, _, mod, _)
  ) and
  fullyQualifiedToYamlFormat(newModelFullyQualified, type2, path) and
  not Extensions::typeModel(spec, type2, path)
select spec.(string), type2, path
