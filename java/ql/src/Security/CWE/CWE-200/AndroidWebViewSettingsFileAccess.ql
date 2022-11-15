/**
 * @name Android WebSettings file access
 * @kind problem
 * @description Enabling access to the file system in a WebView can enable access to sensitive information.
 * @id java/android-websettings-file-access
 * @problem.severity warning
 * @security-severity 6.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-200
 */

import java
import semmle.code.java.frameworks.android.WebView

from MethodAccess ma
where
  ma.getMethod() instanceof CrossOriginAccessMethod and
  ma.getArgument(0).(CompileTimeConstantExpr).getBooleanValue() = true
select ma,
  "WebView setting " + ma.getMethod().getName() +
    " may allow for unauthorized access of sensitive information."
