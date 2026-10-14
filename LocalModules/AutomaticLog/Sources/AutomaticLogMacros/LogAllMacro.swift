import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Type-level `@LogAll` forwards `@Log` with the same options onto every `func` member. A member
// that carries its own `@Log` is left alone, so its options win. The `masked:` names are not
// forwarded: the `@Log` body macro reads them off the enclosing declaration itself, which is
// what lets a function-level `@Log` override the options without dropping a mask.
public struct LogAllMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo _: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let funcDecl = member.as(FunctionDeclSyntax.self),
            funcDecl.body != nil,
            !hasOwnLog(funcDecl)
        else {
            return []
        }

        let options = node.arguments?.as(LabeledExprListSyntax.self)?
            .first(where: { $0.label == nil })?
            .expression.trimmedDescription
        let argumentList = options.map { "(\($0))" } ?? ""
        return [AttributeSyntax(stringLiteral: "@Log\(argumentList)")]
    }

    private static func hasOwnLog(_ funcDecl: FunctionDeclSyntax) -> Bool {
        funcDecl.attributes.contains { element in
            guard case .attribute(let attribute) = element else { return false }
            let name = attribute.attributeName.trimmedDescription
            return name == "Log" || name.hasSuffix(".Log")
        }
    }
}
