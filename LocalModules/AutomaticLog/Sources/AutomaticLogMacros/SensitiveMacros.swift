import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// `@Sensitive` carries no code of its own — it is a marker that `@Loggable` reads.
///
/// Its whole job at expansion time is to reject the two ways the marker could silently
/// do nothing: a computed property, which reflection never sees, and a type that is not
/// `@Loggable`, which never collects the marker.
public struct SensitiveMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: MacroExpansionErrorMessage("'@Sensitive' can only be applied to a stored property")
                )
            )
            return []
        }

        if variable.bindings.contains(where: { $0.accessorBlock != nil && !isObserver($0.accessorBlock!) }) {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        "'@Sensitive' has no effect on a computed property, which is never logged"
                    )
                )
            )
            return []
        }

        if let typeName = enclosingTypeName(in: context), !enclosingTypeIsLoggable(in: context) {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        "'@Sensitive' has no effect here: mark '\(typeName)' with '@Loggable' to collect it"
                    )
                )
            )
        }

        return []
    }

    /// `willSet`/`didSet` still leave the property stored, so the marker works there.
    private static func isObserver(_ accessorBlock: AccessorBlockSyntax) -> Bool {
        guard case .accessors(let accessors) = accessorBlock.accessors else { return false }
        return accessors.allSatisfy {
            $0.accessorSpecifier.tokenKind == .keyword(.willSet) || $0.accessorSpecifier.tokenKind == .keyword(.didSet)
        }
    }

    private static func enclosingType(
        in context: some MacroExpansionContext
    ) -> (name: String, attributes: AttributeListSyntax)? {
        for lexicalContext in context.lexicalContext {
            if let decl = lexicalContext.as(StructDeclSyntax.self) {
                return (decl.name.text, decl.attributes)
            }
            if let decl = lexicalContext.as(ClassDeclSyntax.self) {
                return (decl.name.text, decl.attributes)
            }
            if let decl = lexicalContext.as(ActorDeclSyntax.self) {
                return (decl.name.text, decl.attributes)
            }
            if let decl = lexicalContext.as(EnumDeclSyntax.self) {
                return (decl.name.text, decl.attributes)
            }
        }
        return nil
    }

    private static func enclosingTypeName(in context: some MacroExpansionContext) -> String? {
        enclosingType(in: context)?.name
    }

    private static func enclosingTypeIsLoggable(in context: some MacroExpansionContext) -> Bool {
        guard let attributes = enclosingType(in: context)?.attributes else { return false }
        return attributes.contains { attribute in
            guard case .attribute(let attribute) = attribute else { return false }
            let name = attribute.attributeName.trimmedDescription
            return name == "Loggable" || name.hasSuffix(".Loggable")
        }
    }
}

/// Generates the `SensitiveFieldsProviding` conformance from the type's `@Sensitive` properties.
public struct LoggableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Nothing to add when the conformance is spelled out on the type itself, in which
        // case the field set is hand-written.
        let alreadyConforms =
            declaration.inheritanceClause?.inheritedTypes
            .contains { $0.type.trimmedDescription.hasSuffix("SensitiveFieldsProviding") } ?? false
        guard !alreadyConforms else { return [] }

        let fields = sensitiveFieldNames(in: declaration)

        if fields.isEmpty {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: MacroExpansionWarningMessage(
                        "'@Loggable' has no effect: no property of '\(type.trimmedDescription)' is marked '@Sensitive'"
                    )
                )
            )
        }

        let isPublic = declaration.modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.public) || modifier.name.tokenKind == .keyword(.open)
        }
        let accessLevel = isPublic ? "public " : ""
        let elements = fields.map { "\"\($0)\"" }.joined(separator: ", ")

        return [
            try ExtensionDeclSyntax(
                """
                extension \(type.trimmed): AutomaticLog.SensitiveFieldsProviding {
                    \(raw: accessLevel)static let sensitiveLogFields: Set<String> = [\(raw: elements)]
                }
                """
            )
        ]
    }

    private static func sensitiveFieldNames(in declaration: some DeclGroupSyntax) -> [String] {
        declaration.memberBlock.members.flatMap { member -> [String] in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                variable.attributes.contains(where: isSensitiveAttribute)
            else {
                return []
            }
            return variable.bindings.compactMap { binding in
                binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            }
        }
    }

    private static func isSensitiveAttribute(_ attribute: AttributeListSyntax.Element) -> Bool {
        guard case .attribute(let attribute) = attribute else { return false }
        let name = attribute.attributeName.trimmedDescription
        return name == "Sensitive" || name.hasSuffix(".Sensitive")
    }
}
