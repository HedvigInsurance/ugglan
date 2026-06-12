import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PersistableStoreMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(node: Syntax(node), message: MacroDiagnostic.notAClass)
            )
            return []
        }

        let persisted = persistedProperties(in: classDecl, context: context)
        let accessModifier = accessLevelModifier(for: classDecl)
        let memberPrefix = accessModifier.isEmpty ? "" : "\(accessModifier) "

        let snapshotFields =
            persisted
            .map { "        var \($0.name): \($0.type)" }
            .joined(separator: "\n")
        let initArgs =
            persisted
            .map { "\($0.name): \($0.name)" }
            .joined(separator: ", ")
        let applyAssignments =
            persisted
            .map { "        \($0.name) = snapshot.\($0.name)" }
            .joined(separator: "\n")

        let snapshotBody = persisted.isEmpty ? "" : "\n\(snapshotFields)\n    "
        let snapshotInit = persisted.isEmpty ? "Snapshot()" : "Snapshot(\(initArgs))"
        let applyBody = persisted.isEmpty ? "" : "\n\(applyAssignments)\n    "

        let source: String = """
            extension \(type.trimmedDescription): PersistableAppStore {
                \(memberPrefix)struct Snapshot: Codable, Sendable {\(snapshotBody)}
                \(memberPrefix)var snapshot: Snapshot {
                    \(snapshotInit)
                }
                \(memberPrefix)func apply(snapshot: Snapshot) {\(applyBody)}
            }
            """

        return [try ExtensionDeclSyntax("\(raw: source)")]
    }

    private static func persistedProperties(
        in classDecl: ClassDeclSyntax,
        context: some MacroExpansionContext
    ) -> [(name: String, type: String)] {
        var result: [(name: String, type: String)] = []

        for member in classDecl.memberBlock.members {
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                hasAttribute(variable, named: "Published"),
                !hasAttribute(variable, named: "Transient")
            else { continue }

            for binding in variable.bindings {
                guard
                    let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                else { continue }

                guard let typeAnnotation = binding.typeAnnotation?.type.trimmedDescription else {
                    context.diagnose(
                        Diagnostic(
                            node: Syntax(binding),
                            message: MacroDiagnostic.missingExplicitType(name: identifier)
                        )
                    )
                    continue
                }

                result.append((name: identifier, type: typeAnnotation))
            }
        }

        return result
    }

    private static func hasAttribute(_ variable: VariableDeclSyntax, named name: String) -> Bool {
        variable.attributes.contains { element in
            guard let attribute = element.as(AttributeSyntax.self) else { return false }
            return attribute.attributeName.trimmedDescription == name
        }
    }

    private static func accessLevelModifier(for classDecl: ClassDeclSyntax) -> String {
        for modifier in classDecl.modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.open):
                return "public"
            case .keyword(.package):
                return "package"
            default:
                continue
            }
        }
        return ""
    }
}

public struct TransientMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

enum MacroDiagnostic: DiagnosticMessage {
    case notAClass
    case missingExplicitType(name: String)

    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case .notAClass:
            return "@PersistableStore can only be applied to a class"
        case .missingExplicitType(let name):
            return
                "@PersistableStore requires an explicit type annotation on '\(name)' (e.g. `@Published var \(name): Bool = false`)"
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notAClass:
            return MessageID(domain: "AppStateContainerMacros", id: "notAClass")
        case .missingExplicitType:
            return MessageID(domain: "AppStateContainerMacros", id: "missingExplicitType")
        }
    }
}

@main
struct AppStateContainerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PersistableStoreMacro.self,
        TransientMacro.self,
    ]
}
