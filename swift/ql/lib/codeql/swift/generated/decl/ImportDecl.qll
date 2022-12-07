// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.decl.Decl
import codeql.swift.elements.decl.ModuleDecl
import codeql.swift.elements.decl.ValueDecl

module Generated {
  class ImportDecl extends Synth::TImportDecl, Decl {
    override string getAPrimaryQlClass() { result = "ImportDecl" }

    /**
     * Holds if this import declaration is exported.
     */
    predicate isExported() { Synth::convertImportDeclToRaw(this).(Raw::ImportDecl).isExported() }

    /**
     * Gets the imported module of this import declaration, if it exists.
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    ModuleDecl getImmediateImportedModule() {
      result =
        Synth::convertModuleDeclFromRaw(Synth::convertImportDeclToRaw(this)
              .(Raw::ImportDecl)
              .getImportedModule())
    }

    /**
     * Gets the imported module of this import declaration, if it exists.
     */
    final ModuleDecl getImportedModule() { result = getImmediateImportedModule().resolve() }

    /**
     * Holds if `getImportedModule()` exists.
     */
    final predicate hasImportedModule() { exists(getImportedModule()) }

    /**
     * Gets the `index`th declaration of this import declaration (0-based).
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    ValueDecl getImmediateDeclaration(int index) {
      result =
        Synth::convertValueDeclFromRaw(Synth::convertImportDeclToRaw(this)
              .(Raw::ImportDecl)
              .getDeclaration(index))
    }

    /**
     * Gets the `index`th declaration of this import declaration (0-based).
     */
    final ValueDecl getDeclaration(int index) { result = getImmediateDeclaration(index).resolve() }

    /**
     * Gets any of the declarations of this import declaration.
     */
    final ValueDecl getADeclaration() { result = getDeclaration(_) }

    /**
     * Gets the number of declarations of this import declaration.
     */
    final int getNumberOfDeclarations() { result = count(int i | exists(getDeclaration(i))) }
  }
}
