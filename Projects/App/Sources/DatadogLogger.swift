import Apollo
import DatadogInternal
import DatadogLogs
import DatadogRUM
import Environment
import Foundation
import Logger
import SwiftUI

class DatadogLogger: Logging {
    /// Identical messages logged within this window are dropped, so a repeating log
    /// (a redraw, a retry loop) does not flood Datadog.
    private static let duplicateWindow: TimeInterval = 0.5
    /// Upper bound on tracked messages, so a stream of unique messages cannot grow the cache forever.
    private static let maxTrackedMessages = 200

    private struct LogKey: Hashable {
        let level: String
        let message: String
    }

    private let datadogLogger: LoggerProtocol
    private let lock = NSLock()
    private var lastLoggedAt: [LogKey: TimeInterval] = [:]

    init(datadogLogger: LoggerProtocol) {
        self.datadogLogger = datadogLogger
    }

    /// Returns `false` when the same message was already logged at the same level less than
    /// `duplicateWindow` ago, meaning the caller should skip it.
    private func shouldLog(_ message: String, level: String) -> Bool {
        let key = LogKey(level: level, message: message)
        let now = ProcessInfo.processInfo.systemUptime
        lock.lock()
        defer { lock.unlock() }
        if let previous = lastLoggedAt[key], now - previous < Self.duplicateWindow {
            print("NOT LOGGED \(message)")
            return false
        }
        if lastLoggedAt.count >= Self.maxTrackedMessages {
            lastLoggedAt = lastLoggedAt.filter { now - $0.value < Self.duplicateWindow }
        }
        lastLoggedAt[key] = now
        return true
    }

    func debug(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        guard Environment.current != .production, shouldLog(message, level: "debug") else { return }
        datadogLogger.debug(message, error: error, attributes: attributes)
    }

    /// Sends an INFO log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func info(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        guard shouldLog(message, level: "info") else { return }
        datadogLogger.info(message, error: error, attributes: attributes)
    }

    /// Sends a NOTICE log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func notice(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        guard shouldLog(message, level: "notice") else { return }
        datadogLogger.notice(message, error: error, attributes: attributes)
    }

    /// Sends a WARN log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func warn(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        guard shouldLog(message, level: "warn") else { return }
        datadogLogger.warn(message, error: error, attributes: attributes)
    }

    /// Sends an ERROR log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func error(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        guard shouldLog(message, level: "error") else { return }
        datadogLogger.error(message, error: error, attributes: attributes)
    }

    /// Sends a CRITICAL log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    func critical(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        guard shouldLog(message, level: "critical") else { return }
        datadogLogger.critical(message, error: error, attributes: attributes)
    }

    func addUserAction(
        type: LoggingAction,
        name: String,
        error _: Error? = nil,
        attributes: [AttributeKey: AttributeValue]? = nil
    ) {
        if let attributes {
            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name, attributes: attributes)
        } else {
            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name)
        }
    }

    func addError(
        error: Error,
        type: ErrorSource,
        attributes: [AttributeKey: AttributeValue]?
    ) {
        if let attributes = attributes {
            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource, attributes: attributes)
        } else {
            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource)
        }
    }
}

extension ErrorSource {
    var asRUMErrorSource: RUMErrorSource {
        switch self {
        case .network:
            return .network
        }
    }
}

extension LoggingAction {
    var asRUMUserActionType: RUMActionType {
        switch self {
        case .click:
            return .click
        case .custom:
            return .custom
        }
    }
}

@MainActor
class InterceptingURLSessionClient: NSObject, URLSessionDataDelegate {}
