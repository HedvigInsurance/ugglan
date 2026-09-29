import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import AutomaticLogMacros

private let testMacros: [String: any Macro.Type] = [
    "Log": AutomaticLogMacros.AutomaticLog.self,
    "Masked": MaskedMacro.self,
    "Loggable": LoggableMacro.self,
]

final class LoggableExpansionTests: XCTestCase {
    func testLoggableCollectsTheMaskedPropertyNames() {
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
                    public static let maskedLogFields: Set<String> = ["email", "phone"]
                }
                """,
            macros: testMacros
        )
    }

    func testMaskedWithoutLoggableIsAnError() {
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
            macros: testMacros
        )
    }
}

final class LogMacroExpansionTests: XCTestCase {
    func testListedParameterExpandsToAMaskedDescription() {
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
            macros: testMacros
        )
    }

    func testUnknownMaskedNameIsAnError() {
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
                        let _logArgs: [String: String] = ["token": AutomaticLog.logDescription(token as Any)]
                        handle(token)
                        AutomaticLog.loginClosure("📥 Service exchange(\\(String(describing: _logArgs)))")
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
            macros: testMacros
        )
    }
}
