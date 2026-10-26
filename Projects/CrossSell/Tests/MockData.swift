import Addons
import Foundation
import hCore

@testable import CrossSell

@MainActor
struct MockData {
    static func createMockCrossSellService(
        fetchAddonBanners: @escaping FetchAddonBanners = { _ in
            [
                .init(
                    contractIds: ["contractId"],
                    displayTitle: "title",
                    displayDescription: "description",
                    badges: [],
                    addonType: .travelPlus
                )
            ]
        },
        fetchCrossSell: @escaping FetchCrossSell = { _ in
            .init(
                recommended: nil,
                others: []
            )
        }
    ) -> MockCrossSellService {
        let service = MockCrossSellService(
            fetchCrossSell: fetchCrossSell,
            fetchAddonBanners: fetchAddonBanners
        )
        Dependencies.shared.add(module: Module { () -> CrossSellClient in service })
        return service
    }

    @discardableResult
    static func createMockEventTrackingClient() -> MockEventTrackingClient {
        let client = MockEventTrackingClient()
        Dependencies.shared.add(module: Module { () -> EventTrackingClient in client })
        return client
    }

    @discardableResult
    static func createMockURLOpener() -> MockURLOpener {
        let opener = MockURLOpener()
        Dependencies.shared.add(module: Module { () -> URLOpener in opener })
        return opener
    }
}

enum MockContractError: Error {
    case fetchCrossSells
    case fetchAddonBanners
}

typealias FetchCrossSell = (CrossSellSource) async throws -> CrossSells
typealias FetchAddonBanners = (AddonSource) async throws -> [AddonBanner]

class MockCrossSellService: CrossSellClient {
    var events = [Event]()
    var fetchCrossSell: FetchCrossSell
    var fetchAddonBanners: FetchAddonBanners

    enum Event {
        case getCrossSell
        case getAddonBanners
    }

    init(
        fetchCrossSell: @escaping FetchCrossSell,
        fetchAddonBanners: @escaping FetchAddonBanners,

    ) {
        self.fetchCrossSell = fetchCrossSell
        self.fetchAddonBanners = fetchAddonBanners
    }

    func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        events.append(.getCrossSell)
        let data = try await fetchCrossSell(source)
        return data
    }

    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner] {
        events.append(.getAddonBanners)
        let data = try await fetchAddonBanners(source)
        return data
    }
}

class MockEventTrackingClient: EventTrackingClient {
    var trackedEvents = [TrackedEvent]()

    struct TrackedEvent: Equatable {
        let name: String
        let parameters: [String: String]
    }

    func setCollectionEnabled(_ enabled: Bool) {}

    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append(.init(name: name, parameters: (parameters ?? [:]).mapValues { "\($0)" }))
    }

    func trackScreen(name: String, parameters: [String: Any]?) {}

    func setUserId(_ userId: String?) {}

    func setUserProperty(name: String, value: String?) {}
}

/// Can hold an open the way the real opener waits for an authorization code, until `finishHeldOpen()`.
class MockURLOpener: URLOpener {
    var openedURLs = [URL]()
    var holdsOpens = false
    private var heldOpen: CheckedContinuation<Void, Never>?

    var isHoldingAnOpen: Bool { heldOpen != nil }

    func open(_ url: URL) async {
        openedURLs.append(url)
        if holdsOpens {
            await withCheckedContinuation { heldOpen = $0 }
        }
    }

    func finishHeldOpen() {
        heldOpen?.resume()
        heldOpen = nil
    }
}
