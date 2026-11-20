import Foundation

public class PublicImportantMessagesClientDemo: PublicImportantMessagesClient {
    public init() {}

    public func getMessages() async throws -> [PublicImportantMessage] {
        []
    }
}
