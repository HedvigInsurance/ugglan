import Foundation
import hCore

@MainActor
public final class PendingAppIntentService: PendingAppIntentServiceProtocol {
    public static let pendingTTL: TimeInterval = 5 * 60
    public static let inFlightAutoClearAfter: TimeInterval = 5

    private struct Pending {
        let action: PendingAppIntentAction
        let timestamp: Date
    }

    private var pending: Pending?
    private var inFlight: PendingAppIntentAction?
    private var inFlightExpiry: Date?

    private let clock: () -> Date

    public init(clock: @escaping () -> Date = Date.init) {
        self.clock = clock
    }

    public func store(_ action: PendingAppIntentAction) {
        pending = Pending(action: action, timestamp: clock())
    }

    public func consume() -> PendingAppIntentAction? {
        if let expiry = inFlightExpiry, clock() >= expiry {
            inFlight = nil
            inFlightExpiry = nil
        }

        guard let p = pending else { return nil }
        pending = nil

        if clock().timeIntervalSince(p.timestamp) > Self.pendingTTL {
            return nil
        }

        inFlight = p.action
        inFlightExpiry = clock().addingTimeInterval(Self.inFlightAutoClearAfter)
        return p.action
    }

    public func recoverInFlight() {
        guard let action = inFlight else { return }
        inFlight = nil
        inFlightExpiry = nil
        pending = Pending(action: action, timestamp: clock())
    }
}
