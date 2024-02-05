import Datadog
import Foundation
import hGraphQL

extension Logger: Logging {
    public func debug(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        self.log(level: .debug, message: message, error: error, attributes: attributes)
    }

    /// Sends an INFO log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    public func info(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        self.log(level: .info, message: message, error: error, attributes: attributes)
    }

    /// Sends a NOTICE log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    public func notice(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        self.log(level: .notice, message: message, error: error, attributes: attributes)
    }

    /// Sends a WARN log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    public func warn(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        self.log(level: .warn, message: message, error: error, attributes: attributes)
    }

    /// Sends an ERROR log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    public func error(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        self.log(level: .error, message: message, error: error, attributes: attributes)
    }

    /// Sends a CRITICAL log message.
    /// - Parameters:
    ///   - message: the message to be logged
    ///   - error: `Error` instance to be logged with its properties
    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
    /// the same key already exist in this logger, it will be overridden (just for this message).
    public func critical(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
        self.log(level: .critical, message: message, error: error, attributes: attributes)
    }

    public func addUserAction(
        type: LoggingAction,
        name: String,
        error: Error? = nil,
        attributes: [AttributeKey: AttributeValue]? = nil
    ) {
        if let attributes {
            Global.rum.addUserAction(type: type.asRUMUserActionType, name: name, attributes: attributes)
        } else {
            Global.rum.addUserAction(type: type.asRUMUserActionType, name: name)
        }
    }
}

extension LoggingAction {
    var asRUMUserActionType: RUMUserActionType {
        switch self {
        case .click:
            return .click
        case .custom:
            return .custom
        }
    }
}
