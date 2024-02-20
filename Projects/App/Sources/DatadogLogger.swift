import DatadogLogs
import DatadogRUM
import Foundation
import Logging
import hGraphQL

extension LoggerProtocol {
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
            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name, attributes: attributes)
        } else {
            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name)
        }
    }

    public func addError(
        error: Error,
        type: hGraphQL.ErrorSource,
        attributes: [hGraphQL.AttributeKey: hGraphQL.AttributeValue]?
    ) {
        if let attributes = attributes {
            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource, attributes: attributes)
        } else {
            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource)
        }
    }
}

//extension Logger: Logging {
//    public func debug(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
//        let logger = Logger.create()
//        logger.log(level: .debug, message: message, error: error, attributes: attributes)
//    }
//
//    /// Sends an INFO log message.
//    /// - Parameters:
//    ///   - message: the message to be logged
//    ///   - error: `Error` instance to be logged with its properties
//    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
//    /// the same key already exist in this logger, it will be overridden (just for this message).
//    public func info(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
//        let logger = Logger.create()
//        logger.log(level: .info, message: message, error: error, attributes: attributes)
//    }
//
//    /// Sends a NOTICE log message.
//    /// - Parameters:
//    ///   - message: the message to be logged
//    ///   - error: `Error` instance to be logged with its properties
//    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
//    /// the same key already exist in this logger, it will be overridden (just for this message).
//    public func notice(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
//        let logger = Logger.create()
//        logger.log(level: .notice, message: message, error: error, attributes: attributes)
//    }
//
//    /// Sends a WARN log message.
//    /// - Parameters:
//    ///   - message: the message to be logged
//    ///   - error: `Error` instance to be logged with its properties
//    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
//    /// the same key already exist in this logger, it will be overridden (just for this message).
//    public func warn(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
//        let logger = Logger.create()
//        logger.log(level: .warn, message: message, error: error, attributes: attributes)
//    }
//
//    /// Sends an ERROR log message.
//    /// - Parameters:
//    ///   - message: the message to be logged
//    ///   - error: `Error` instance to be logged with its properties
//    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
//    /// the same key already exist in this logger, it will be overridden (just for this message).
//    public func error(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
//        let logger = Logger.create()
//        logger.log(level: .error, message: message, error: error, attributes: attributes)
//    }
//
//    /// Sends a CRITICAL log message.
//    /// - Parameters:
//    ///   - message: the message to be logged
//    ///   - error: `Error` instance to be logged with its properties
//    ///   - attributes: a dictionary of attributes to add for this message. If an attribute with
//    /// the same key already exist in this logger, it will be overridden (just for this message).
//    public func critical(_ message: String, error: Error? = nil, attributes: [AttributeKey: AttributeValue]? = nil) {
//        let logger = Logger.create()
//        logger.log(level: .critical, message: message, error: error, attributes: attributes)
//    }
//
//    public func addUserAction(
//        type: LoggingAction,
//        name: String,
//        error: Error? = nil,
//        attributes: [AttributeKey: AttributeValue]? = nil
//    ) {
//        if let attributes {
////            Global.rum.addUserAction(type: type.asRUMUserActionType, name: name, attributes: attributes)
//            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name, attributes: attributes)
//        } else {
////            Global.rum.addUserAction(type: type.asRUMUserActionType, name: name)
//            RUMMonitor.shared().addAction(type: type.asRUMUserActionType, name: name)
//        }
//    }
//
//    public func addError(
//        error: Error,
//        type: hGraphQL.ErrorSource,
//        attributes: [hGraphQL.AttributeKey: hGraphQL.AttributeValue]?
//    ) {
//        if let attributes = attributes {
////            Global.rum.addError(error: error, source: type.asRUMErrorSource, attributes: attributes)
//            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource, attributes: attributes)
//        } else {
////            Global.rum.addError(error: error, source: type.asRUMErrorSource)
//            RUMMonitor.shared().addError(error: error, source: type.asRUMErrorSource)
//        }
//    }
//}

extension hGraphQL.ErrorSource {
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
