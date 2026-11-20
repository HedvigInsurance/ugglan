import Foundation
@preconcurrency import HedvigShared
import Logger
import hCore

/// Writes Kotlin's log lines to `log`. Lines that arrive before `initialSetup` makes `log` the Datadog logger are held,
/// and `logIsReady()` writes them in order.
final class AppLogSink: NSObject, IosLogSink, @unchecked Sendable {
    static let shared = AppLogSink()

    @MainActor private var held: [(priority: LogPriority, message: String, tag: String)]? = []

    /// Called by Kotlin on whichever thread logged the line.
    func log(priority: LogPriority, tag: String?, message: String) {
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                if self.held != nil {
                    self.held?.append((priority, message, tag ?? ""))
                } else {
                    Self.write(priority, message, tag: tag ?? "")
                }
            }
        }
    }

    @MainActor func logIsReady() {
        let lines = held ?? []
        held = nil
        for line in lines {
            Self.write(line.priority, line.message, tag: line.tag)
        }
    }

    @MainActor private static func write(_ priority: LogPriority, _ message: String, tag: String) {
        let attributes: [AttributeKey: AttributeValue] = ["source": "kotlin", "tag": tag]
        switch priority.nsEnum {
        case .verbose, .debug: hCore.log.debug(message, error: nil, attributes: attributes)
        case .info: hCore.log.info(message, error: nil, attributes: attributes)
        case .warn: hCore.log.warn(message, error: nil, attributes: attributes)
        case .error: hCore.log.error(message, error: nil, attributes: attributes)
        case .assert: hCore.log.critical(message, error: nil, attributes: attributes)
        @unknown default: hCore.log.error(message, error: nil, attributes: attributes)
        }
    }
}
