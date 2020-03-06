//
//  ApplicationState.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Flow
import Foundation
import UIKit

struct ApplicationState {
    public static let lastNewsSeenKey = "lastNewsSeen"

    enum Screen: String {
        case marketing, onboardingChat, offer, loggedIn, languagePicker

        func isOneOf(_ possibilities: Set<Self>) -> Bool {
            possibilities.contains(self)
        }
    }

    private static let key = "applicationState"

    static func preserveState(_ screen: Screen) {
        UserDefaults.standard.set(screen.rawValue, forKey: key)
    }

    static var currentState: Screen? {
        guard
            let applicationStateRawValue = UserDefaults.standard.value(forKey: key) as? String,
            let applicationState = Screen(rawValue: applicationStateRawValue) else {
            return nil
        }
        return applicationState
    }

    static func hasPreviousState() -> Bool {
        return UserDefaults.standard.value(forKey: key) as? String != nil
    }

    private static let firebaseMessagingTokenKey = "firebaseMessagingToken"

    static func setFirebaseMessagingToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ApplicationState.firebaseMessagingTokenKey)
    }

    static func getFirebaseMessagingToken() -> String? {
        UserDefaults.standard.value(forKey: firebaseMessagingTokenKey) as? String
    }

    static func hasLastNewsSeen() -> Bool {
        return UserDefaults.standard.value(forKey: lastNewsSeenKey) as? String != nil
    }

    static func getLastNewsSeen() -> String {
        return UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "2.8.3"
    }

    static func setLastNewsSeen(appVersion: String) {
        UserDefaults.standard.set(appVersion, forKey: ApplicationState.lastNewsSeenKey)
    }

    private static let targetEnvironmentKey = "targetEnvironment"

    enum Environment: Hashable {
        case production
        case staging
        case custom(endpointURL: URL, wsEndpointURL: URL, assetsEndpointURL: URL)

        fileprivate struct RawCustomStorage: Codable {
            let endpointURL: URL
            let wsEndpointURL: URL
            let assetsEndpointURL: URL
        }

        var rawValue: String {
            switch self {
            case .production:
                return "production"
            case .staging:
                return "staging"
            case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL):
                let rawCustomStorage = RawCustomStorage(
                    endpointURL: endpointURL,
                    wsEndpointURL: wsEndpointURL,
                    assetsEndpointURL: assetsEndpointURL
                )
                let data = try? JSONEncoder().encode(rawCustomStorage)

                if let data = data {
                    return String(data: data, encoding: .utf8) ?? "staging"
                }

                return "staging"
            }
        }

        var displayName: String {
            switch self {
            case .production:
                return "production"
            case .staging:
                return "staging"
            case .custom:
                return "custom"
            }
        }

        init?(rawValue: String) {
            switch rawValue {
            case "production":
                self = .production
            case "staging":
                self = .staging
            default:
                guard let data = rawValue.data(using: .utf8) else {
                    return nil
                }

                guard let rawCustomStorage = try? JSONDecoder().decode(RawCustomStorage.self, from: data) else {
                    return nil
                }

                self = .custom(
                    endpointURL: rawCustomStorage.endpointURL,
                    wsEndpointURL: rawCustomStorage.wsEndpointURL,
                    assetsEndpointURL: rawCustomStorage.assetsEndpointURL
                )
            }
        }
    }

    static func setTargetEnvironment(_ environment: Environment) {
        UserDefaults.standard.set(environment.rawValue, forKey: targetEnvironmentKey)
    }

    static var hasOverridenTargetEnvironment: Bool {
        return UserDefaults.standard.value(forKey: targetEnvironmentKey) != nil
    }

    static func getTargetEnvironment() -> Environment {
        guard
            let targetEnvirontmentRawValue = UserDefaults.standard.value(forKey: targetEnvironmentKey) as? String,
            let targetEnvironment = Environment(rawValue: targetEnvirontmentRawValue) else {
            #if APP_VARIANT_PRODUCTION
                return .production
            #elseif APP_VARIANT_DEV
                return .staging
            #else
                return .production
            #endif
        }
        return targetEnvironment
    }
}
