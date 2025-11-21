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

        let metadata = extractFunctionMetadata(from: funcDecl, in: context)
        var statements = generateEntryLogStatements(for: metadata)

        if metadata.hasReturnType {
            statements.append(contentsOf: generateReturnTypeStatements(for: metadata, body: body))
        } else {
            statements.append(contentsOf: generateVoidFunctionStatements(for: metadata, body: body))
        }

        return statements
    }

    // MARK: - Function Metadata

    private struct FunctionMetadata {
        let functionName: String
        let fullFunctionName: String
        let parameterNames: [String]
        let hasReturnType: Bool
        let isAsync: Bool
        let isThrows: Bool
        let returnType: String
    }

    private static func extractFunctionMetadata(
        from funcDecl: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> FunctionMetadata {
        let functionName = funcDecl.name.text
        let typeName = findParentTypeName(of: funcDecl, in: context)
        let fullFunctionName = typeName.isEmpty ? functionName : "\(typeName).\(functionName)"

        let parameters = funcDecl.signature.parameterClause.parameters
        let parameterNames = parameters.map { $0.firstName.text }

        let hasReturnType = funcDecl.signature.returnClause != nil
        let isAsync = funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrows = funcDecl.signature.effectSpecifiers?.throwsClause != nil
        let returnType =
            funcDecl.signature.returnClause?.type.description.trimmingCharacters(in: .whitespaces) ?? "Void"

        return FunctionMetadata(
            functionName: functionName,
            fullFunctionName: fullFunctionName,
            parameterNames: parameterNames,
            hasReturnType: hasReturnType,
            isAsync: isAsync,
            isThrows: isThrows,
            returnType: returnType
        )
    }

    // MARK: - Entry Log Generation

    private static func generateEntryLogStatements(for metadata: FunctionMetadata) -> [CodeBlockItemSyntax] {
        let dictElements = metadata.parameterNames
            .map { "\"\($0)\": String(describing: \($0))" }
            .joined(separator: ", ")

        let logSetupCode = """
            let _logArgs: [String: String] = [\(dictElements)]
            AutomaticLog.loginClosure("➡️ \(metadata.fullFunctionName) called with: " + String(describing: _logArgs))
            """

        let parsedSetup = Parser.parse(source: logSetupCode)
        return Array(parsedSetup.statements)
    }

    // MARK: - Return Type Function Handling

    private static func generateReturnTypeStatements(
        for metadata: FunctionMetadata,
        body: CodeBlockSyntax
    ) -> [CodeBlockItemSyntax] {
        let bodyCode = body.statements.description
        let returnCode =
            metadata.isThrows
            ? generateThrowingReturnCode(for: metadata, bodyCode: bodyCode)
            : generateNonThrowingReturnCode(for: metadata, bodyCode: bodyCode)

        let parsedReturn = Parser.parse(source: returnCode)
        return Array(parsedReturn.statements)
    }

    private static func generateThrowingReturnCode(
        for metadata: FunctionMetadata,
        bodyCode: String
    ) -> String {
        let awaitKeyword = metadata.isAsync ? "await " : ""
        let asyncKeyword = metadata.isAsync ? "async " : ""

        return """
            do {
                let _logResult = try \(awaitKeyword){ () \(asyncKeyword)throws -> \(metadata.returnType) in
                    \(bodyCode)
                }()
                AutomaticLog.loginClosure("⬅️ \(metadata.fullFunctionName) returned: " + String(describing: _logResult))
                return _logResult
            } catch {
                AutomaticLog.loginClosure("❌ \(metadata.fullFunctionName) threw error: " + String(describing: error))
                throw error
            }
            """
    }

    private static func generateNonThrowingReturnCode(
        for metadata: FunctionMetadata,
        bodyCode: String
    ) -> String {
        let closureSignature = buildClosureSignature(for: metadata)
        let closureCall = metadata.isAsync ? "await " : ""

        return """
            let _logResult =\(closureCall){\(closureSignature)in
                \(bodyCode)
            }()
            AutomaticLog.loginClosure("⬅️ \(metadata.fullFunctionName) returned: " + String(describing: _logResult))
            return _logResult
            """
    }

    private static func buildClosureSignature(for metadata: FunctionMetadata) -> String {
        guard metadata.isAsync || metadata.returnType != "Void" else {
            return ""
        }

        var signature = " () "
        if metadata.isAsync {
            signature += "async "
        }
        signature += "-> \(metadata.returnType) "
        return signature
    }

    // MARK: - Void Function Handling

    private static func generateVoidFunctionStatements(
        for metadata: FunctionMetadata,
        body: CodeBlockSyntax
    ) -> [CodeBlockItemSyntax] {
        if metadata.isThrows {
            return generateThrowingVoidStatements(for: metadata, body: body)
        } else {
            return generateNonThrowingVoidStatements(for: metadata, body: body)
        }
    }

    private static func generateThrowingVoidStatements(
        for metadata: FunctionMetadata,
        body: CodeBlockSyntax
    ) -> [CodeBlockItemSyntax] {
        let throwingCode = """
            do {
                \(body.statements.description)
                AutomaticLog.loginClosure("⬅️ \(metadata.fullFunctionName) completed")
            } catch {
                AutomaticLog.loginClosure("❌ \(metadata.fullFunctionName) threw error: " + String(describing: error))
                throw error
            }
            """

        let parsedThrowing = Parser.parse(source: throwingCode)
        return Array(parsedThrowing.statements)
    }

    private static func generateNonThrowingVoidStatements(
        for metadata: FunctionMetadata,
        body: CodeBlockSyntax
    ) -> [CodeBlockItemSyntax] {
        var statements = Array(body.statements)

        let completionCode = """
            AutomaticLog.loginClosure("⬅️ \(metadata.fullFunctionName) completed")
            """

        let parsedCompletion = Parser.parse(source: completionCode)
        statements.append(contentsOf: parsedCompletion.statements)

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
