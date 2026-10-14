import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import AutomaticLogMacros

final class LogAllExpansionTests: XCTestCase {
    func testLogAllForwardsOptionsOntoFunctionsWithoutTheirOwn() {
        assertMacroExpansion(
            """
            @LogAll(.error, masked: ["token"])
            struct Service {
                func exchange(token: String, id: String) {
                    handle(id)
                }

                @Log
                func plain() {
                    handle()
                }

                var state: Int { 1 }
            }
            """,
            expandedSource: """
                struct Service {
                    @Log(.error)
                    func exchange(token: String, id: String) {
                        handle(id)
                    }

                    @Log
                    func plain() {
                        handle()
                    }

                    var state: Int { 1 }
                }
                """,
            macros: ["LogAll": LogAllMacro.self]
        )
    }
}
