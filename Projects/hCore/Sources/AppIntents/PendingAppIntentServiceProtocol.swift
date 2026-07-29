import Combine
import Foundation

@MainActor
public protocol PendingAppIntentServiceProtocol: AnyObject {
    /// Fires every time `store(_:)` is called. Subscribers should call `consume()`
    /// on each emission to atomically claim the pending action.
    ///
    /// `recoverInFlight()` deliberately does NOT emit on this publisher — recovered
    /// actions are picked up via the next subscriber's initial drain instead, so
    /// they survive the brief window between forced-logout and the loggedIn
    /// view tree being rebuilt.
    var storedPublisher: AnyPublisher<Void, Never> { get }

    func store(_ action: PendingAppIntentAction)
    func consume() -> PendingAppIntentAction?
    func recoverInFlight()
}
