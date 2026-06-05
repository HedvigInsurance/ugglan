import Foundation

@MainActor
public protocol PendingAppIntentServiceProtocol: AnyObject {
    func store(_ action: PendingAppIntentAction)
    func consume() -> PendingAppIntentAction?
    func recoverInFlight()
}
