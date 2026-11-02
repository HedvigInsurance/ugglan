import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import AutomaticLogMacros

final class LogAllExpansionTests {
    @Test
    func logAllForwardsOptionsOntoFunctionsWithoutTheirOwn() {
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
            macroSpecs: ["LogAll": MacroSpec(type: LogAllMacro.self)],
            failureHandler: recordMacroFailure
        )
    }
}
