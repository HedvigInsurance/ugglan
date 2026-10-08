import CrossSell
import Foundation
import SwiftUI
import hCore

@MainActor
public class ChatCrossSellViewModel: ObservableObject {
    @Published private(set) var recommended: RecommendedCrossSell?

    @Inject private var crossSellClient: CrossSellClient
    private let chatService: ChatServiceProtocol

    // The gate repeats on every five-second poll and an empty response is final, so the
    // fetch is latched: an ineligible member costs no cross-sell requests at all, and an
    // eligible one costs exactly one.
    private var hasFetched = false

    // Set by either answer. Keeps a late poll from reviving a prompt the member has already
    // dealt with, even if the mutation that records it never reaches the server.
    private var hasRetired = false

    init(chatService: ChatServiceProtocol) {
        self.chatService = chatService
    }

    var title: String { recommended?.title ?? L10n.crossSellBannerText }
    var subtitle: String? { recommended?.description }
    var openTitle: String { recommended?.buttonTitle ?? L10n.crossSellButton }
    var dismissTitle: String { L10n.generalNoThanks }

    // Spoken when the prompt arrives. Both buttons carry short titles that only make sense
    // under the offer, so the announcement leads with the copy that frames them.
    var voiceOverAnnouncement: String {
        [title, subtitle].compactMap { $0 }.joined(separator: ". ")
    }

    func handle(showCrossSales: Bool, conversationId: String) async {
        guard showCrossSales, !hasFetched, !hasRetired, !conversationId.isEmpty else { return }
        hasFetched = true

        guard let crossSells = try? await crossSellClient.getCrossSell(source: .inChat),
            let recommended = crossSells.recommended
        else { return }

        withAnimation {
            self.recommended = recommended
        }
        track(.prompted)
    }

    func dismiss() async {
        guard recommended != nil else { return }
        retire(event: .dismissed)
        try? await chatService.hideCrossSales()
    }

    func open() async {
        guard let recommended else { return }
        let destination = recommended.destination
        // Recorded before the member leaves for the store, so a click is never lost to the
        // app being backgrounded.
        retire(event: .clicked)
        await open(destination)
        try? await chatService.hideCrossSales()
    }

    // Hides the prompt before the mutation runs: the member should not wait on the network,
    // and a failed call must not make the prompt reappear on the next poll. The server call
    // is idempotent, so the only cost of losing it is that the prompt returns next session.
    private func retire(event: InChatCrossSellTrackingEvent) {
        hasRetired = true
        track(event)
        withAnimation {
            recommended = nil
        }
    }

    // Mirrors Android's `logInChatCrossSell`: one action name with the variant in an "event"
    // attribute, so both platforms answer a single query. A second name or a renamed key here
    // halves the funnel rather than failing.
    private func track(_ event: InChatCrossSellTrackingEvent) {
        let name = "inChatCrossSell"
        let attributes: [String: any Encodable] = [
            "event": event.rawValue
        ]
        log.addUserAction(type: .custom, name: name, error: nil, attributes: attributes)
    }

    private func open(_ destination: RecommendedCrossSell.Destination) async {
        switch destination {
        case let .storeURL(urlString):
            if let urlString, let url = URL(string: urlString) {
                await Dependencies.urlOpener.open(url)
            }
        case let .deepLink(link):
            if let url = URL(string: link) {
                NotificationCenter.default.post(name: .openDeepLink, object: url)
            }
        }
    }
}

// Raw values are the attribute values the funnel groups on; they mirror Android's
// `InChatCrossSellTrackingEvent`.
enum InChatCrossSellTrackingEvent: String {
    case prompted
    case dismissed
    case clicked
}
