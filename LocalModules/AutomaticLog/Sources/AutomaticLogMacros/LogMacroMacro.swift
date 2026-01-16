import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutomaticLog: BodyMacro {
    // MARK: - Log Options Parsing

    struct ParsedLogOptions: OptionSet {
        let rawValue: Int

        static let output = ParsedLogOptions(rawValue: 1 << 0)
        static let error = ParsedLogOptions(rawValue: 1 << 1)

        static let all: ParsedLogOptions = [.output, .error]
    }

    private static func parseLogOptions(from attribute: AttributeSyntax) -> ParsedLogOptions {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self),
            let firstArgument = arguments.first
        else {
            return .all
        }

        let argText = firstArgument.expression.description.trimmingCharacters(in: .whitespaces)

        if argText == ".all" {
            return .all
        }

        var options: ParsedLogOptions = []

        if argText.contains(".output") {
            options.insert(.output)
        }
        if argText.contains(".error") {
            options.insert(.error)
        }

        return options.isEmpty ? .all : options
    }

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

        let options = parseLogOptions(from: attribute)
        let metadata = extractFunctionMetadata(from: funcDecl, in: context, options: options)
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
        let options: ParsedLogOptions
    }

    private static func extractFunctionMetadata(
        from funcDecl: FunctionDeclSyntax,
        in context: some MacroExpansionContext,
        options: ParsedLogOptions
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
            returnType: returnType,
            options: options
        )
    }

    // MARK: - Entry Log Generation

    private static func generateEntryLogStatements(for metadata: FunctionMetadata) -> [CodeBlockItemSyntax] {
        guard !metadata.parameterNames.isEmpty else {
            return []
        }

        let dictElements = metadata.parameterNames
            .map { "\"\($0)\": String(describing: \($0))" }
            .joined(separator: ", ")

        let logSetupCode = """
            let _logArgs: [String: String] = [\(dictElements)]
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

        let logOutput = metadata.options.contains(.output)
        let logError = metadata.options.contains(.error)

        let argsString =
            metadata.parameterNames.isEmpty ? "" : "(\\(String(describing: _logArgs)))"

        let successLog: String
        if logOutput {
            successLog = """
                AutomaticLog.loginClosure("✅ \(metadata.fullFunctionName)\(argsString) → \\(String(describing: _logResult))")
                """
        } else {
            successLog = """
                AutomaticLog.loginClosure("📥 \(metadata.fullFunctionName)\(argsString)")
                """
        }

        let errorLogStatement: String
        if logError {
            errorLogStatement = """
                AutomaticLog.loginClosure("⚠️ \(metadata.fullFunctionName)\(argsString) → \\(String(describing: error))")
                """
        } else {
            errorLogStatement = """
                AutomaticLog.loginClosure("📥 \(metadata.fullFunctionName)\(argsString)")
                """
        }

        return """
            do {
                let _logResult = try \(awaitKeyword){ () \(asyncKeyword)throws -> \(metadata.returnType) in
                    \(bodyCode)
                }()
                \(successLog)
                return _logResult
            } catch {
                \(errorLogStatement)
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

        let logOutput = metadata.options.contains(.output)

        let argsString =
            metadata.parameterNames.isEmpty ? "" : "(\\(String(describing: _logArgs)))"

        let successLog: String
        if logOutput {
            successLog = """
                AutomaticLog.loginClosure("✅ \(metadata.fullFunctionName)\(argsString) → \\(String(describing: _logResult))")
                """
        } else {
            successLog = """
                AutomaticLog.loginClosure("📥 \(metadata.fullFunctionName)\(argsString)")
                """
        }

        return """
            let _logResult =\(closureCall){\(closureSignature)in
                \(bodyCode)
            }()
            \(successLog)
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
        let logOutput = metadata.options.contains(.output)
        let logError = metadata.options.contains(.error)

        let argsString =
            metadata.parameterNames.isEmpty ? "" : "(\\(String(describing: _logArgs)))"

        let successLog: String
        if logOutput {
            successLog = """
                AutomaticLog.loginClosure("✅ \(metadata.fullFunctionName)\(argsString)")
                """
        } else {
            successLog = """
                AutomaticLog.loginClosure("📥 \(metadata.fullFunctionName)\(argsString)")
                """
        }

        let errorLogStatement: String
        if logError {
            errorLogStatement = """
                AutomaticLog.loginClosure("⚠️ \(metadata.fullFunctionName)\(argsString) → \\(String(describing: error))")
                """
        } else {
            errorLogStatement = """
                AutomaticLog.loginClosure("📥 \(metadata.fullFunctionName)\(argsString)")
                """
        }

        let throwingCode = """
            do {
                \(body.statements.description)
                \(successLog)
            } catch {
                \(errorLogStatement)
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

        let logOutput = metadata.options.contains(.output)

        let argsString =
            metadata.parameterNames.isEmpty ? "" : "(\\(String(describing: _logArgs)))"

        let successLog: String
        if logOutput {
            successLog = """
                AutomaticLog.loginClosure("✅ \(metadata.fullFunctionName)\(argsString)")
                """
        } else {
            successLog = """
                AutomaticLog.loginClosure("📥 \(metadata.fullFunctionName)\(argsString)")
                """
        }

        let parsedLog = Parser.parse(source: successLog)
        statements.append(contentsOf: parsedLog.statements)

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
