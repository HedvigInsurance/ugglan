import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutomaticLog: BodyMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self),
            let body = funcDecl.body
        else {
            return []
        }

        // Function name
        let functionName = funcDecl.name.text

        // Get the parent type name (class, struct, enum, or actor)
        let typeName = findParentTypeName(of: declaration, in: context)

        // Parameter names
        let parameters = funcDecl.signature.parameterClause.parameters
        let paramNames = parameters.map { param in
            param.firstName.text
        }

        // Build logging statements by parsing source code
        let dictElements = paramNames.map { "\"\($0)\": String(describing: \($0))" }.joined(separator: ", ")

        let fullFunctionName = typeName.isEmpty ? functionName : "\(typeName).\(functionName)"

        let logSetupCode = """
            let _logArgs: [String: String] = [\(dictElements)]
            AutomaticLog.loginClosure("➡️ \(fullFunctionName) called with: " + String(describing: _logArgs))
            """

        let parsedSetup = Parser.parse(source: logSetupCode)
        var statements: [CodeBlockItemSyntax] = Array(parsedSetup.statements)

        // Check if function has a return type
        let hasReturnType = funcDecl.signature.returnClause != nil

        if hasReturnType {
            // Wrap original body in closure and capture result
            let bodyCode = body.statements.description

            // Check for async/throws
            let isAsync = funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil
            let isThrows = funcDecl.signature.effectSpecifiers?.throwsClause != nil
            let returnType =
                funcDecl.signature.returnClause?.type.description.trimmingCharacters(in: .whitespaces) ?? "Void"

            let returnCode: String
            if isThrows {
                // Build with try-catch to log errors
                let awaitKeyword = isAsync ? "await " : ""
                let asyncKeyword = isAsync ? "async " : ""

                returnCode = """
                    do {
                        let _logResult = try \(awaitKeyword){ () \(asyncKeyword)throws -> \(returnType) in
                            \(bodyCode)
                        }()
                        AutomaticLog.loginClosure("⬅️ \(fullFunctionName) returned: " + String(describing: _logResult))
                        return _logResult
                    } catch {
                        AutomaticLog.loginClosure("❌ \(fullFunctionName) threw error: " + String(describing: error))
                        throw error
                    }
                    """
            } else {
                // Build closure signature for non-throwing functions
                var closureSignature = ""
                if isAsync || returnType != "Void" {
                    closureSignature = " () "
                    if isAsync {
                        closureSignature += "async "
                    }
                    closureSignature += "-> \(returnType) "
                }

                // Build closure call
                var closureCall = ""
                if isAsync {
                    closureCall += "await "
                }

                returnCode = """
                    let _logResult =\(closureCall){\(closureSignature)in
                        \(bodyCode)
                    }()
                    AutomaticLog.loginClosure("⬅️ \(fullFunctionName) returned: " + String(describing: _logResult))
                    return _logResult
                    """
            }

            let parsedReturn = Parser.parse(source: returnCode)
            statements.append(contentsOf: parsedReturn.statements)
        } else {
            // Function has no return type (returns Void)
            // Check if it can throw
            let isThrows = funcDecl.signature.effectSpecifiers?.throwsClause != nil

            if isThrows {
                // Wrap in do-catch to log errors
                let throwingCode = """
                    do {
                        \(body.statements.description)
                        AutomaticLog.loginClosure("⬅️ \(fullFunctionName) completed")
                    } catch {
                        AutomaticLog.loginClosure("❌ \(fullFunctionName) threw error: " + String(describing: error))
                        throw error
                    }
                    """
                let parsedThrowing = Parser.parse(source: throwingCode)
                statements.append(contentsOf: parsedThrowing.statements)
            } else {
                // Add original body statements
                statements.append(contentsOf: body.statements)

                // Add completion log
                let completionCode = """
                    AutomaticLog.loginClosure("⬅️ \(fullFunctionName) completed")
                    """
                let parsedCompletion = Parser.parse(source: completionCode)
                statements.append(contentsOf: parsedCompletion.statements)
            }
        }

        return statements
    }

    /// Finds the parent type name (class, struct, enum, or actor) of the given declaration
    private static func findParentTypeName(
        of declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) -> String {
        // Use lexical context to find parent types - iterate in reverse to get the closest parent
        for lexicalContext in context.lexicalContext.reversed() {
            // Check for class declaration
            if let classDecl = lexicalContext.as(ClassDeclSyntax.self) {
                return classDecl.name.text
            }
            // Check for struct declaration
            if let structDecl = lexicalContext.as(StructDeclSyntax.self) {
                return structDecl.name.text
            }
            // Check for enum declaration
            if let enumDecl = lexicalContext.as(EnumDeclSyntax.self) {
                return enumDecl.name.text
            }
            // Check for actor declaration
            if let actorDecl = lexicalContext.as(ActorDeclSyntax.self) {
                return actorDecl.name.text
            }
            // Check for extension declaration
            if let extensionDecl = lexicalContext.as(ExtensionDeclSyntax.self) {
                return extensionDecl.extendedType.description.trimmingCharacters(in: .whitespaces)
            }
        }

        return ""
    }
}

@main
struct AutomaticLogPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutomaticLog.self
    ]
}
