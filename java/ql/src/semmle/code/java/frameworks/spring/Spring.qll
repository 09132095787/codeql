import java

import semmle.code.java.frameworks.spring.SpringAbstractRef
import semmle.code.java.frameworks.spring.SpringAlias
import semmle.code.java.frameworks.spring.SpringArgType
import semmle.code.java.frameworks.spring.SpringAttribute
import semmle.code.java.frameworks.spring.SpringAutowire
import semmle.code.java.frameworks.spring.SpringBean
import semmle.code.java.frameworks.spring.SpringBeanFile
import semmle.code.java.frameworks.spring.SpringBeanRefType
import semmle.code.java.frameworks.spring.SpringComponentScan
import semmle.code.java.frameworks.spring.SpringConstructorArg
import semmle.code.java.frameworks.spring.SpringController
import semmle.code.java.frameworks.spring.SpringDescription
import semmle.code.java.frameworks.spring.SpringEntry
import semmle.code.java.frameworks.spring.SpringFlex
import semmle.code.java.frameworks.spring.SpringIdRef
import semmle.code.java.frameworks.spring.SpringImport
import semmle.code.java.frameworks.spring.SpringInitializingBean
import semmle.code.java.frameworks.spring.SpringKey
import semmle.code.java.frameworks.spring.SpringList
import semmle.code.java.frameworks.spring.SpringListOrSet
import semmle.code.java.frameworks.spring.SpringLookupMethod
import semmle.code.java.frameworks.spring.SpringMap
import semmle.code.java.frameworks.spring.SpringMergable
import semmle.code.java.frameworks.spring.SpringMeta
import semmle.code.java.frameworks.spring.SpringNull
import semmle.code.java.frameworks.spring.SpringProfile
import semmle.code.java.frameworks.spring.SpringProp
import semmle.code.java.frameworks.spring.SpringProperty
import semmle.code.java.frameworks.spring.SpringProps
import semmle.code.java.frameworks.spring.SpringQualifier
import semmle.code.java.frameworks.spring.SpringRef
import semmle.code.java.frameworks.spring.SpringReplacedMethod
import semmle.code.java.frameworks.spring.SpringSet
import semmle.code.java.frameworks.spring.SpringValue
import semmle.code.java.frameworks.spring.SpringXMLElement

import semmle.code.java.frameworks.spring.metrics.MetricSpringBean
import semmle.code.java.frameworks.spring.metrics.MetricSpringBeanFile
