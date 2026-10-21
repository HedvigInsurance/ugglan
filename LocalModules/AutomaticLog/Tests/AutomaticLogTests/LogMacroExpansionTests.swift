import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import AutomaticLogMacros

private let testMacros: [String: MacroSpec] = [
    "Log": MacroSpec(type: AutomaticLogMacros.AutomaticLog.self),
    "Masked": MacroSpec(type: MaskedMacro.self),
    "Loggable": MacroSpec(type: LoggableMacro.self),
]

final class LoggableExpansionTests {
    @Test
    func loggableCollectsTheMaskedPropertyNames() {
        assertMacroExpansion(
            """
            @Loggable
            public struct Member {
                let name: String
                @Masked let email: String
                @Masked var phone: String?
            }
            """,
            expandedSource: """

                public struct Member {
                    let name: String
                    let email: String
                    var phone: String?
                }

                extension Member: AutomaticLog.MaskedFieldsProviding {
                    public nonisolated static let maskedLogFields: Set<String> = ["email", "phone"]
                }
                """,
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }

    @Test
    func maskedWithoutLoggableIsAnError() {
        assertMacroExpansion(
            """
            struct Member {
                @Masked let email: String
            }
            """,
            expandedSource: """
                struct Member {
                    let email: String
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@Masked' has no effect here: mark 'Member' with '@Loggable' to collect it",
                    line: 2,
                    column: 5
                )
            ],
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }
}

final class LogMacroExpansionTests {
    @Test
    func listedParameterExpandsToAMaskedDescription() {
        assertMacroExpansion(
            """
            struct Service {
                @Log(masked: ["token"])
                func exchange(token: String, id: String) {
                    handle(id)
                }
            }
            """,
            expandedSource: """
                struct Service {
                    func exchange(token: String, id: String) {
                        let _logArgs: [String: String] = ["token": AutomaticLog.maskedLogDescription(token as Any), "id": AutomaticLog.logDescription(id as Any)]
                        handle(id)
                        AutomaticLog.loginClosure("✅ Service exchange(\\(String(describing: _logArgs)))")
                    }
                }
                """,
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }

    @Test
    func enclosingLogAllMaskedNamesAreInherited() {
        assertMacroExpansion(
            """
            @LogAll(masked: ["token", "missing"])
            struct Service {
                @Log
                func exchange(token: String, id: String) {
                    handle(id)
                }
            }
            """,
            expandedSource: """
                @LogAll(masked: ["token", "missing"])
                struct Service {
                    func exchange(token: String, id: String) {
                        let _logArgs: [String: String] = ["token": AutomaticLog.maskedLogDescription(token as Any), "id": AutomaticLog.logDescription(id as Any)]
                        handle(id)
                        AutomaticLog.loginClosure("✅ Service exchange(\\(String(describing: _logArgs)))")
                    }
                }
                """,
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }

    @Test
    func unknownMaskedNameIsAnError() {
        assertMacroExpansion(
            """
            struct Service {
                @Log(.error, masked: ["tokn"])
                func exchange(token: String) {
                    handle(token)
                }
            }
            """,
            expandedSource: """
                struct Service {
                    func exchange(token: String) {
                        handle(token)
                    }
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'tokn' is not a parameter of 'exchange' — parameters are: token",
                    line: 2,
                    column: 5
                )
            ],
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }
}
