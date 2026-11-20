import Foundation
@preconcurrency import HedvigShared
import Logger
import hCore

/// Writes Kotlin's log lines to `log` (or to the logger it is given). Lines that arrive before `initialSetup` makes
/// `log` the Datadog logger are held, and `logIsReady()` writes them in order.
final class AppLogSink: NSObject, IosLogSink, @unchecked Sendable {
    static let shared = AppLogSink()

    private let logger: @MainActor @Sendable () -> any Logging
    @MainActor private var held: [(priority: LogPriority, message: String, tag: String)]? = []

    init(logger: @escaping @MainActor @Sendable () -> any Logging = { hCore.log }) {
        self.logger = logger
        super.init()
    }

    /// Called by Kotlin on whichever thread logged the line.
    func log(priority: LogPriority, tag: String?, message: String) {
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                if self.held != nil {
                    self.held?.append((priority, message, tag ?? ""))
                } else {
                    self.write(priority, message, tag: tag ?? "")
                }
            }
        }
    }

    @MainActor func logIsReady() {
        let lines = held ?? []
        held = nil
        for line in lines {
            write(line.priority, line.message, tag: line.tag)
        }
    }

    @MainActor private func write(_ priority: LogPriority, _ message: String, tag: String) {
        let attributes: [AttributeKey: AttributeValue] = ["source": "kotlin", "tag": tag]
        let log = logger()
        switch priority.nsEnum {
        case .verbose, .debug: log.debug(message, error: nil, attributes: attributes)
        case .info: log.info(message, error: nil, attributes: attributes)
        case .warn: log.warn(message, error: nil, attributes: attributes)
        case .error: log.error(message, error: nil, attributes: attributes)
        case .assert: log.critical(message, error: nil, attributes: attributes)
        @unknown default: log.error(message, error: nil, attributes: attributes)
        }
    }
}
