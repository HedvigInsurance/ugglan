import AppStateContainerMacros
import Observation
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

private let testMacros: [String: MacroSpec] = [
    "PersistableStore": MacroSpec(type: PersistableStoreMacro.self),
    "Transient": MacroSpec(type: TransientMacro.self),
]

// Macro assertions report via XCTFail, which Swift Testing does not see, so failures go through a handler.
private func recordMacroFailure(_ failure: TestFailureSpec) {
    Issue.record(
        Comment(rawValue: failure.message),
        sourceLocation: SourceLocation(
            fileID: failure.location.fileID,
            filePath: failure.location.filePath,
            line: failure.location.line,
            column: failure.location.column
        )
    )
}

final class PersistableStoreMacroTests {
    /// Every typed stored `var` is persisted except `@Transient` and `@Inject` ones.
    @Test
    func persistsAllStoredVarsExceptTransientAndInject() {
        assertMacroExpansion(
            """
            @PersistableStore
            class MyStore {
                @ObservationIgnored var published: Int = 0
                var plain: String = ""
                @Transient var transientState: Bool = false
                @Inject var service: Foo
                let constant: Int = 1
                static var shared: Int = 2
                var computed: Int { 5 }
            }
            """,
            expandedSource: """
                class MyStore {
                    @ObservationIgnored var published: Int = 0
                    var plain: String = ""
                    var transientState: Bool = false
                    @Inject var service: Foo
                    let constant: Int = 1
                    static var shared: Int = 2
                    var computed: Int { 5 }
                }

                extension MyStore: PersistableAppStore {
                    struct Snapshot: Codable, Sendable {
                        var published: Int
                        var plain: String
                    }
                    var snapshot: Snapshot {
                        Snapshot(published: published, plain: plain)
                    }
                    func apply(snapshot: Snapshot) {
                        published = snapshot.published
                        plain = snapshot.plain
                    }
                }
                """,
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }

    /// A stored property with `didSet`/`willSet` observers is still stored state and is persisted.
    @Test
    func persistsStoredVarWithObservers() {
        assertMacroExpansion(
            """
            @PersistableStore
            class MyStore {
                var count: Int = 0 {
                    didSet { print(count) }
                }
            }
            """,
            expandedSource: """
                class MyStore {
                    var count: Int = 0 {
                        didSet { print(count) }
                    }
                }

                extension MyStore: PersistableAppStore {
                    struct Snapshot: Codable, Sendable {
                        var count: Int
                    }
                    var snapshot: Snapshot {
                        Snapshot(count: count)
                    }
                    func apply(snapshot: Snapshot) {
                        count = snapshot.count
                    }
                }
                """,
            macroSpecs: testMacros,
            failureHandler: recordMacroFailure
        )
    }
}
