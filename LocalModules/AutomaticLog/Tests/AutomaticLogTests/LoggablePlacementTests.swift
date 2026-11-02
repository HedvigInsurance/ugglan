import AutomaticLog
import Testing

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

final class LoggablePlacementTests {
    @Test
    func nestedTypeIsMasked() {
        let described = logDescription(Outer.Inner(title: "Address", value: "Storgatan 1"))

        #expect(described.contains("title: Address"), Comment(rawValue: described))
        #expect(described.contains("Storgatan") == false, Comment(rawValue: described))
    }

    @Test
    func mainActorTypeIsMaskedFromANonisolatedContext() async {
        let value = await MainActor.run { Isolated(id: "1", url: "https://signed") }
        let described = await Task.detached { logDescription(value) }.value

        #expect(described.contains("id: 1"), Comment(rawValue: described))
        #expect(described.contains("signed") == false, Comment(rawValue: described))
    }
}
