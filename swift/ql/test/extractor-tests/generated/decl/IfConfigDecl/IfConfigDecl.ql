// generated by codegen/codegen.py
import codeql.swift.elements
import TestUtils

from IfConfigDecl x, ModuleDecl getModule, int getNumberOfActiveElements
where
  toBeTested(x) and
  not x.isUnknown() and
  getModule = x.getModule() and
  getNumberOfActiveElements = x.getNumberOfActiveElements()
select x, "getModule:", getModule, "getNumberOfActiveElements:", getNumberOfActiveElements
