import AuthenticationCore
import Foundation
@preconcurrency import HedvigShared
import hCore
import hGraphQL

@MainActor
final class PublicImportantMessagesClientShared: PublicImportantMessagesClient {
    @Inject private var graph: IosGraphHolder

    func getMessages() async throws -> [PublicImportantMessage] {
        try await kotlinRead { graph.publicImportantMessagesReads().messages() }
            .map(PublicImportantMessage.init(item:))
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
