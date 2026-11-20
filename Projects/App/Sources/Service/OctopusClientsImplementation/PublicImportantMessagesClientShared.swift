import AuthenticationCore
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import hCore
import hGraphQL

@MainActor
final class PublicImportantMessagesClientShared: PublicImportantMessagesClient {
    @Inject private var graph: IosGraphHolder

    func getMessages() async throws -> [PublicImportantMessage] {
        try await Self.messages(from: { graph.publicImportantMessagesReads().messages() })
    }

    static func messages(
        from read: () -> NativeSuspend<[PublicImportantMessageItem], Error, KotlinUnit>
    ) async throws -> [PublicImportantMessage] {
        do {
            return try await asyncFunction(for: read()).map(PublicImportantMessage.init(item:))
        } catch {
            throw GraphQLError(readError: error)
        }
    }
}

extension PublicImportantMessage {
    init(item: PublicImportantMessageItem) {
        let severity: Severity
        switch item.severity {
        case .info: severity = .info
        case .error: severity = .error
        default: severity = .warning
        }
        // The link opens in a SafariView, which only takes http and https.
        let link: Link? = {
            guard let urlString = item.linkUrl, let text = item.linkButtonText, let url = URL(string: urlString),
                let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https"
            else { return nil }
            return Link(url: url, text: text)
        }()
        self.init(id: item.id, message: item.message, severity: severity, link: link)
    }
}
