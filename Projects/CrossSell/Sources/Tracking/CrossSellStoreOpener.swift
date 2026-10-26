import Foundation
import hCore

/// Sends members from a cross-sell offer to the web store, counting each launch once.
///
/// The store link waits for an authorization code before anything opens, so a second tap on the same
/// offer meanwhile is dropped rather than opening the store and counting a click a second time.
@MainActor
public final class CrossSellStoreOpener {
    public static let shared = CrossSellStoreOpener()

    private var opening = Set<String>()

    init() {}

    /// Returns true when this call opened the store, false when the offer has no link or that link is still opening.
    @discardableResult
    public func open(_ crossSell: CrossSell, from source: CrossSellSource) async -> Bool {
        guard let link = crossSell.webActionURL, let url = URL(string: link), opening.insert(link).inserted else {
            return false
        }
        defer { opening.remove(link) }
        // Recorded before the member leaves for the store, so a click is never lost to the app being backgrounded.
        crossSell.track(.clicked, from: source)
        await Dependencies.urlOpener.open(url)
        return true
    }
}
