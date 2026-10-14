import AutomaticLog
import XCTest

private struct Outer {
    @Loggable
    struct Inner: Codable {
        let title: String
        @Masked let value: String
    }
}

@Loggable
@MainActor
private struct Isolated: Codable {
    let id: String
    @Masked let url: String
}

final class LoggablePlacementTests: XCTestCase {
    func testNestedTypeIsMasked() {
        let described = logDescription(Outer.Inner(title: "Address", value: "Storgatan 1"))

        XCTAssertTrue(described.contains("title: Address"), described)
        XCTAssertFalse(described.contains("Storgatan"), described)
    }

    func testMainActorTypeIsMaskedFromANonisolatedContext() async {
        let value = await MainActor.run { Isolated(id: "1", url: "https://signed") }
        let described = await Task.detached { logDescription(value) }.value

        XCTAssertTrue(described.contains("id: 1"), described)
        XCTAssertFalse(described.contains("signed"), described)
    }
}
