// generated by codegen/codegen.py
import codeql.swift.elements.AstNode
import codeql.swift.elements.Callable
import codeql.swift.elements.Comment
import codeql.swift.elements.DbFile
import codeql.swift.elements.DbLocation
import codeql.swift.elements.Diagnostics
import codeql.swift.elements.Element
import codeql.swift.elements.ErrorElement
import codeql.swift.elements.File
import codeql.swift.elements.Locatable
import codeql.swift.elements.Location
import codeql.swift.elements.UnknownFile
import codeql.swift.elements.UnknownLocation
import codeql.swift.elements.UnspecifiedElement
import codeql.swift.elements.decl.AbstractFunctionDecl
import codeql.swift.elements.decl.AbstractStorageDecl
import codeql.swift.elements.decl.AbstractTypeParamDecl
import codeql.swift.elements.decl.AccessorDecl
import codeql.swift.elements.decl.AssociatedTypeDecl
import codeql.swift.elements.decl.ClassDecl
import codeql.swift.elements.decl.ConcreteFuncDecl
import codeql.swift.elements.decl.ConcreteVarDecl
import codeql.swift.elements.decl.ConstructorDecl
import codeql.swift.elements.decl.Decl
import codeql.swift.elements.decl.DestructorDecl
import codeql.swift.elements.decl.EnumCaseDecl
import codeql.swift.elements.decl.EnumDecl
import codeql.swift.elements.decl.EnumElementDecl
import codeql.swift.elements.decl.ExtensionDecl
import codeql.swift.elements.decl.FuncDecl
import codeql.swift.elements.decl.GenericContext
import codeql.swift.elements.decl.GenericTypeDecl
import codeql.swift.elements.decl.GenericTypeParamDecl
import codeql.swift.elements.decl.IfConfigDecl
import codeql.swift.elements.decl.ImportDecl
import codeql.swift.elements.decl.InfixOperatorDecl
import codeql.swift.elements.decl.IterableDeclContext
import codeql.swift.elements.decl.MissingMemberDecl
import codeql.swift.elements.decl.ModuleDecl
import codeql.swift.elements.decl.NominalTypeDecl
import codeql.swift.elements.decl.OpaqueTypeDecl
import codeql.swift.elements.decl.OperatorDecl
import codeql.swift.elements.decl.ParamDecl
import codeql.swift.elements.decl.PatternBindingDecl
import codeql.swift.elements.decl.PostfixOperatorDecl
import codeql.swift.elements.decl.PoundDiagnosticDecl
import codeql.swift.elements.decl.PrecedenceGroupDecl
import codeql.swift.elements.decl.PrefixOperatorDecl
import codeql.swift.elements.decl.ProtocolDecl
import codeql.swift.elements.decl.StructDecl
import codeql.swift.elements.decl.SubscriptDecl
import codeql.swift.elements.decl.TopLevelCodeDecl
import codeql.swift.elements.decl.TypeAliasDecl
import codeql.swift.elements.decl.TypeDecl
import codeql.swift.elements.decl.ValueDecl
import codeql.swift.elements.decl.VarDecl
import codeql.swift.elements.expr.AbiSafeConversionExpr
import codeql.swift.elements.expr.AbstractClosureExpr
import codeql.swift.elements.expr.AnyHashableErasureExpr
import codeql.swift.elements.expr.AnyTryExpr
import codeql.swift.elements.expr.AppliedPropertyWrapperExpr
import codeql.swift.elements.expr.ApplyExpr
import codeql.swift.elements.expr.ArchetypeToSuperExpr
import codeql.swift.elements.expr.Argument
import codeql.swift.elements.expr.ArrayExpr
import codeql.swift.elements.expr.ArrayToPointerExpr
import codeql.swift.elements.expr.AssignExpr
import codeql.swift.elements.expr.AutoClosureExpr
import codeql.swift.elements.expr.AwaitExpr
import codeql.swift.elements.expr.BinaryExpr
import codeql.swift.elements.expr.BindOptionalExpr
import codeql.swift.elements.expr.BooleanLiteralExpr
import codeql.swift.elements.expr.BridgeFromObjCExpr
import codeql.swift.elements.expr.BridgeToObjCExpr
import codeql.swift.elements.expr.BuiltinLiteralExpr
import codeql.swift.elements.expr.CallExpr
import codeql.swift.elements.expr.CaptureListExpr
import codeql.swift.elements.expr.CheckedCastExpr
import codeql.swift.elements.expr.ClassMetatypeToObjectExpr
import codeql.swift.elements.expr.ClosureExpr
import codeql.swift.elements.expr.CoerceExpr
import codeql.swift.elements.expr.CollectionExpr
import codeql.swift.elements.expr.CollectionUpcastConversionExpr
import codeql.swift.elements.expr.ConditionalBridgeFromObjCExpr
import codeql.swift.elements.expr.ConditionalCheckedCastExpr
import codeql.swift.elements.expr.ConstructorRefCallExpr
import codeql.swift.elements.expr.CovariantFunctionConversionExpr
import codeql.swift.elements.expr.CovariantReturnConversionExpr
import codeql.swift.elements.expr.DeclRefExpr
import codeql.swift.elements.expr.DefaultArgumentExpr
import codeql.swift.elements.expr.DerivedToBaseExpr
import codeql.swift.elements.expr.DestructureTupleExpr
import codeql.swift.elements.expr.DictionaryExpr
import codeql.swift.elements.expr.DifferentiableFunctionExpr
import codeql.swift.elements.expr.DifferentiableFunctionExtractOriginalExpr
import codeql.swift.elements.expr.DiscardAssignmentExpr
import codeql.swift.elements.expr.DotSelfExpr
import codeql.swift.elements.expr.DotSyntaxBaseIgnoredExpr
import codeql.swift.elements.expr.DotSyntaxCallExpr
import codeql.swift.elements.expr.DynamicLookupExpr
import codeql.swift.elements.expr.DynamicMemberRefExpr
import codeql.swift.elements.expr.DynamicSubscriptExpr
import codeql.swift.elements.expr.DynamicTypeExpr
import codeql.swift.elements.expr.EnumIsCaseExpr
import codeql.swift.elements.expr.ErasureExpr
import codeql.swift.elements.expr.ErrorExpr
import codeql.swift.elements.expr.ExistentialMetatypeToObjectExpr
import codeql.swift.elements.expr.ExplicitCastExpr
import codeql.swift.elements.expr.Expr
import codeql.swift.elements.expr.FloatLiteralExpr
import codeql.swift.elements.expr.ForceTryExpr
import codeql.swift.elements.expr.ForceValueExpr
import codeql.swift.elements.expr.ForcedCheckedCastExpr
import codeql.swift.elements.expr.ForeignObjectConversionExpr
import codeql.swift.elements.expr.FunctionConversionExpr
import codeql.swift.elements.expr.IdentityExpr
import codeql.swift.elements.expr.IfExpr
import codeql.swift.elements.expr.ImplicitConversionExpr
import codeql.swift.elements.expr.InOutExpr
import codeql.swift.elements.expr.InOutToPointerExpr
import codeql.swift.elements.expr.InjectIntoOptionalExpr
import codeql.swift.elements.expr.IntegerLiteralExpr
import codeql.swift.elements.expr.InterpolatedStringLiteralExpr
import codeql.swift.elements.expr.IsExpr
import codeql.swift.elements.expr.KeyPathApplicationExpr
import codeql.swift.elements.expr.KeyPathDotExpr
import codeql.swift.elements.expr.KeyPathExpr
import codeql.swift.elements.expr.LazyInitializerExpr
import codeql.swift.elements.expr.LinearFunctionExpr
import codeql.swift.elements.expr.LinearFunctionExtractOriginalExpr
import codeql.swift.elements.expr.LinearToDifferentiableFunctionExpr
import codeql.swift.elements.expr.LiteralExpr
import codeql.swift.elements.expr.LoadExpr
import codeql.swift.elements.expr.LookupExpr
import codeql.swift.elements.expr.MagicIdentifierLiteralExpr
import codeql.swift.elements.expr.MakeTemporarilyEscapableExpr
import codeql.swift.elements.expr.MemberRefExpr
import codeql.swift.elements.expr.MetatypeConversionExpr
import codeql.swift.elements.expr.MethodLookupExpr
import codeql.swift.elements.expr.NilLiteralExpr
import codeql.swift.elements.expr.NumberLiteralExpr
import codeql.swift.elements.expr.ObjCSelectorExpr
import codeql.swift.elements.expr.ObjectLiteralExpr
import codeql.swift.elements.expr.OneWayExpr
import codeql.swift.elements.expr.OpaqueValueExpr
import codeql.swift.elements.expr.OpenExistentialExpr
import codeql.swift.elements.expr.OptionalEvaluationExpr
import codeql.swift.elements.expr.OptionalTryExpr
import codeql.swift.elements.expr.OtherConstructorDeclRefExpr
import codeql.swift.elements.expr.OverloadedDeclRefExpr
import codeql.swift.elements.expr.ParenExpr
import codeql.swift.elements.expr.PointerToPointerExpr
import codeql.swift.elements.expr.PostfixUnaryExpr
import codeql.swift.elements.expr.PrefixUnaryExpr
import codeql.swift.elements.expr.PropertyWrapperValuePlaceholderExpr
import codeql.swift.elements.expr.ProtocolMetatypeToObjectExpr
import codeql.swift.elements.expr.RebindSelfInConstructorExpr
import codeql.swift.elements.expr.RegexLiteralExpr
import codeql.swift.elements.expr.SelfApplyExpr
import codeql.swift.elements.expr.SequenceExpr
import codeql.swift.elements.expr.StringLiteralExpr
import codeql.swift.elements.expr.StringToPointerExpr
import codeql.swift.elements.expr.SubscriptExpr
import codeql.swift.elements.expr.SuperRefExpr
import codeql.swift.elements.expr.TapExpr
import codeql.swift.elements.expr.TryExpr
import codeql.swift.elements.expr.TupleElementExpr
import codeql.swift.elements.expr.TupleExpr
import codeql.swift.elements.expr.TypeExpr
import codeql.swift.elements.expr.UnderlyingToOpaqueExpr
import codeql.swift.elements.expr.UnevaluatedInstanceExpr
import codeql.swift.elements.expr.UnresolvedDeclRefExpr
import codeql.swift.elements.expr.UnresolvedDotExpr
import codeql.swift.elements.expr.UnresolvedMemberChainResultExpr
import codeql.swift.elements.expr.UnresolvedMemberExpr
import codeql.swift.elements.expr.UnresolvedPatternExpr
import codeql.swift.elements.expr.UnresolvedSpecializeExpr
import codeql.swift.elements.expr.UnresolvedTypeConversionExpr
import codeql.swift.elements.expr.VarargExpansionExpr
import codeql.swift.elements.pattern.AnyPattern
import codeql.swift.elements.pattern.BindingPattern
import codeql.swift.elements.pattern.BoolPattern
import codeql.swift.elements.pattern.EnumElementPattern
import codeql.swift.elements.pattern.ExprPattern
import codeql.swift.elements.pattern.IsPattern
import codeql.swift.elements.pattern.NamedPattern
import codeql.swift.elements.pattern.OptionalSomePattern
import codeql.swift.elements.pattern.ParenPattern
import codeql.swift.elements.pattern.Pattern
import codeql.swift.elements.pattern.TuplePattern
import codeql.swift.elements.pattern.TypedPattern
import codeql.swift.elements.stmt.BraceStmt
import codeql.swift.elements.stmt.BreakStmt
import codeql.swift.elements.stmt.CaseLabelItem
import codeql.swift.elements.stmt.CaseStmt
import codeql.swift.elements.stmt.ConditionElement
import codeql.swift.elements.stmt.ContinueStmt
import codeql.swift.elements.stmt.DeferStmt
import codeql.swift.elements.stmt.DoCatchStmt
import codeql.swift.elements.stmt.DoStmt
import codeql.swift.elements.stmt.FailStmt
import codeql.swift.elements.stmt.FallthroughStmt
import codeql.swift.elements.stmt.ForEachStmt
import codeql.swift.elements.stmt.GuardStmt
import codeql.swift.elements.stmt.IfStmt
import codeql.swift.elements.stmt.LabeledConditionalStmt
import codeql.swift.elements.stmt.LabeledStmt
import codeql.swift.elements.stmt.PoundAssertStmt
import codeql.swift.elements.stmt.RepeatWhileStmt
import codeql.swift.elements.stmt.ReturnStmt
import codeql.swift.elements.stmt.Stmt
import codeql.swift.elements.stmt.StmtCondition
import codeql.swift.elements.stmt.SwitchStmt
import codeql.swift.elements.stmt.ThrowStmt
import codeql.swift.elements.stmt.WhileStmt
import codeql.swift.elements.stmt.YieldStmt
import codeql.swift.elements.type.AnyBuiltinIntegerType
import codeql.swift.elements.type.AnyFunctionType
import codeql.swift.elements.type.AnyGenericType
import codeql.swift.elements.type.AnyMetatypeType
import codeql.swift.elements.type.ArchetypeType
import codeql.swift.elements.type.ArraySliceType
import codeql.swift.elements.type.BoundGenericClassType
import codeql.swift.elements.type.BoundGenericEnumType
import codeql.swift.elements.type.BoundGenericStructType
import codeql.swift.elements.type.BoundGenericType
import codeql.swift.elements.type.BuiltinBridgeObjectType
import codeql.swift.elements.type.BuiltinDefaultActorStorageType
import codeql.swift.elements.type.BuiltinExecutorType
import codeql.swift.elements.type.BuiltinFloatType
import codeql.swift.elements.type.BuiltinIntegerLiteralType
import codeql.swift.elements.type.BuiltinIntegerType
import codeql.swift.elements.type.BuiltinJobType
import codeql.swift.elements.type.BuiltinNativeObjectType
import codeql.swift.elements.type.BuiltinRawPointerType
import codeql.swift.elements.type.BuiltinRawUnsafeContinuationType
import codeql.swift.elements.type.BuiltinType
import codeql.swift.elements.type.BuiltinUnsafeValueBufferType
import codeql.swift.elements.type.BuiltinVectorType
import codeql.swift.elements.type.ClassType
import codeql.swift.elements.type.DependentMemberType
import codeql.swift.elements.type.DictionaryType
import codeql.swift.elements.type.DynamicSelfType
import codeql.swift.elements.type.EnumType
import codeql.swift.elements.type.ErrorType
import codeql.swift.elements.type.ExistentialMetatypeType
import codeql.swift.elements.type.ExistentialType
import codeql.swift.elements.type.FunctionType
import codeql.swift.elements.type.GenericFunctionType
import codeql.swift.elements.type.GenericTypeParamType
import codeql.swift.elements.type.InOutType
import codeql.swift.elements.type.LValueType
import codeql.swift.elements.type.MetatypeType
import codeql.swift.elements.type.ModuleType
import codeql.swift.elements.type.NominalOrBoundGenericNominalType
import codeql.swift.elements.type.NominalType
import codeql.swift.elements.type.OpaqueTypeArchetypeType
import codeql.swift.elements.type.OpenedArchetypeType
import codeql.swift.elements.type.OptionalType
import codeql.swift.elements.type.ParameterizedProtocolType
import codeql.swift.elements.type.ParenType
import codeql.swift.elements.type.PrimaryArchetypeType
import codeql.swift.elements.type.ProtocolCompositionType
import codeql.swift.elements.type.ProtocolType
import codeql.swift.elements.type.ReferenceStorageType
import codeql.swift.elements.type.StructType
import codeql.swift.elements.type.SubstitutableType
import codeql.swift.elements.type.SugarType
import codeql.swift.elements.type.SyntaxSugarType
import codeql.swift.elements.type.TupleType
import codeql.swift.elements.type.Type
import codeql.swift.elements.type.TypeAliasType
import codeql.swift.elements.type.TypeRepr
import codeql.swift.elements.type.UnarySyntaxSugarType
import codeql.swift.elements.type.UnboundGenericType
import codeql.swift.elements.type.UnmanagedStorageType
import codeql.swift.elements.type.UnownedStorageType
import codeql.swift.elements.type.UnresolvedType
import codeql.swift.elements.type.VariadicSequenceType
import codeql.swift.elements.type.WeakStorageType
