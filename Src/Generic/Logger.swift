//
//  Logger.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-05-14.
//

import Apollo
import Foundation
import UIKit

private struct LogMessage: Encodable {
    let text: String
}

struct Logger {
    private static let queue = DispatchQueue(label: "Logger")

    private static func log(input: LoggingInput) {
        #if DEBUG
        // don't send anything when debugging
        #else
            let client: ApolloClient = Dependencies.shared.resolve()
            client.perform(mutation: LogMutation(input: input), queue: queue).onValue { _ in }
        #endif
    }

    static func debug(_ message: String?) {
        guard let message = message else {
            return
        }

        print("DEBUG 💛 \(Date()) - \(message)")

        if let json = try? JSONEncoder().encode(LogMessage(text: message)), let jsonString = String(data: json, encoding: .utf8) {
            log(input: LoggingInput(timestamp: Date().currentTimeMillis().description, source: .ios, payload: jsonString, severity: .debug))
        }
    }

    static func info(_ message: String?) {
        guard let message = message else {
            return
        }

        print("INFO 💙 \(Date()) - \(message)")

        if let json = try? JSONEncoder().encode(LogMessage(text: message)), let jsonString = String(data: json, encoding: .utf8) {
            log(input: LoggingInput(timestamp: Date().currentTimeMillis().description, source: .ios, payload: jsonString, severity: .info))
        }
    }

    static func warning(_ message: String?) {
        guard let message = message else {
            return
        }

        print("WARNING 💜 \(Date()) - \(message)")

        if let json = try? JSONEncoder().encode(LogMessage(text: message)), let jsonString = String(data: json, encoding: .utf8) {
            log(input: LoggingInput(timestamp: Date().currentTimeMillis().description, source: .ios, payload: jsonString, severity: .warning))
        }
    }

    static func error(_ message: String?) {
        guard let message = message else {
            return
        }

        print("ERROR 💥 \(Date()) - \(message)")

        if let json = try? JSONEncoder().encode(LogMessage(text: message)), let jsonString = String(data: json, encoding: .utf8) {
            log(input: LoggingInput(timestamp: Date().currentTimeMillis().description, source: .ios, payload: jsonString, severity: .error))
        }
    }
}
