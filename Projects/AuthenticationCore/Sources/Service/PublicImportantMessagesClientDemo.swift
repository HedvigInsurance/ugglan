import Foundation

public class PublicImportantMessagesClientDemo: PublicImportantMessagesClient {
    public init() {}

    public func getMessages() async throws -> [PublicImportantMessage] {
        [
            .init(
                id: "demo-error",
                message: "Logging in is not working right now. We are on it.",
                severity: .error,
                link: .init(url: URL(string: "https://www.hedvig.com")!, text: "Read more")
            ),
            .init(
                id: "demo-info",
                message: "Our phone lines are closed today. Chat with us in the app.",
                severity: .info,
                link: nil
            ),
        ]
    }
}
