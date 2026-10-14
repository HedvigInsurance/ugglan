import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Type-level `@LogAll` forwards `@Log` onto every `func` member. A member that carries its own
// `@Log` is left alone, so the function-level annotation always wins.
public struct LogAllMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let funcDecl = member.as(FunctionDeclSyntax.self),
            funcDecl.body != nil,
            !hasOwnLog(funcDecl)
        else {
            return []
        }

        let parameterNames = funcDecl.signature.parameterClause.parameters
            .map { ($0.secondName ?? $0.firstName).text }

        var arguments: [String] = []
        if let labeled = node.arguments?.as(LabeledExprListSyntax.self) {
            if let options = labeled.first(where: { $0.label == nil }) {
                arguments.append(options.expression.trimmedDescription)
            }
            // A type-wide list is not expected to match every function, and `@Log` rejects a
            // name that is not a parameter, so only the names this function has are forwarded.
            let masked = maskedNames(in: labeled).filter { parameterNames.contains($0) }
            if !masked.isEmpty {
                arguments.append("masked: [\(masked.map { "\"\($0)\"" }.joined(separator: ", "))]")
            }
        }

        let argumentList = arguments.isEmpty ? "" : "(\(arguments.joined(separator: ", ")))"
        return [AttributeSyntax(stringLiteral: "@Log\(argumentList)")]
    }

    private static func hasOwnLog(_ funcDecl: FunctionDeclSyntax) -> Bool {
        funcDecl.attributes.contains { element in
            guard case .attribute(let attribute) = element else { return false }
            let name = attribute.attributeName.trimmedDescription
            return name == "Log" || name.hasSuffix(".Log")
        }
    }

    private static func maskedNames(in arguments: LabeledExprListSyntax) -> [String] {
        guard let masked = arguments.first(where: { $0.label?.text == "masked" }),
            let array = masked.expression.as(ArrayExprSyntax.self)
        else {
            return []
        }
        return array.elements.compactMap {
            $0.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        }
    }
}
