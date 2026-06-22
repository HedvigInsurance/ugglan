import AppStateContainerMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let testMacros: [String: Macro.Type] = [
    "PersistableStore": PersistableStoreMacro.self,
    "Transient": TransientMacro.self,
]

final class PersistableStoreMacroTests: XCTestCase {
    /// Every stored `var` with an explicit type is persisted regardless of `@Published`.
    /// Only `@Transient` (in-memory state) and `@Inject` (DI services, not Codable) are excluded,
    /// alongside `let`, `static`, and computed properties which can never be snapshot state.
    func testPersistsAllStoredVarsExceptTransientAndInject() {
        assertMacroExpansion(
            """
            @PersistableStore
            class MyStore {
                @Published var published: Int = 0
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
                    @Published var published: Int = 0
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
            macros: testMacros
        )
    }

    /// A stored property with `didSet`/`willSet` observers is still stored state and is persisted.
    func testPersistsStoredVarWithObservers() {
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
            macros: testMacros
        )
    }
}
