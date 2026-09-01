import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import AutomaticLogMacros

private let testMacros: [String: any Macro.Type] = [
    "Log": AutomaticLogMacros.AutomaticLog.self,
    "Sensitive": SensitiveMacro.self,
    "Loggable": LoggableMacro.self,
]

final class LoggableExpansionTests: XCTestCase {
    func testLoggableCollectsTheSensitivePropertyNames() {
        assertMacroExpansion(
            """
            @Loggable
            public struct Member {
                let name: String
                @Sensitive let email: String
                @Sensitive var phone: String?
            }
            """,
            expandedSource: """

                public struct Member {
                    let name: String
                    let email: String
                    var phone: String?
                }

                extension Member: AutomaticLog.SensitiveFieldsProviding {
                    public static let sensitiveLogFields: Set<String> = ["email", "phone"]
                }
                """,
            macros: testMacros
        )
    }

    func testSensitiveWithoutLoggableIsAnError() {
        assertMacroExpansion(
            """
            struct Member {
                @Sensitive let email: String
            }
            """,
            expandedSource: """
                struct Member {
                    let email: String
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@Sensitive' has no effect here: mark 'Member' with '@Loggable' to collect it",
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
                @Log(sensitive: ["token"])
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

    func testUnknownSensitiveNameIsAnError() {
        assertMacroExpansion(
            """
            struct Service {
                @Log(.error, sensitive: ["tokn"])
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
