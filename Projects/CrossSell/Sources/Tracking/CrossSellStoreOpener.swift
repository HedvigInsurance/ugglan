import Foundation
import hCore

/// Sends members from a cross-sell offer to the web store, counting each launch that opened it once.
///
/// The store link waits for an authorization code before anything opens, so a second tap on the same
/// offer meanwhile is dropped rather than opening the store and counting a click a second time.
@MainActor
public final class CrossSellStoreOpener {
    public static let shared = CrossSellStoreOpener()

    private var opening = Set<String>()

    init() {}

    /// Returns true when this call opened the store, false when the offer has no link, that link is still opening,
    /// or the system did not open it.
    @discardableResult
    public func open(_ crossSell: CrossSell) async -> Bool {
        guard let link = crossSell.webActionURL, let url = URL(string: link), opening.insert(link).inserted else {
            return false
        }
        defer { opening.remove(link) }
        let opened = await Dependencies.urlOpener.open(url)
        if opened {
            crossSell.track(.clicked)
        }
        return opened
    }
}
