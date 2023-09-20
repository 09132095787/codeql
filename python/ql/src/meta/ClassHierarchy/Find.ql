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
