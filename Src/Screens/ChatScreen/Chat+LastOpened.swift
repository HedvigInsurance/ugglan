//
//  Chat+LastOpened.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-08.
//

import Flow
import Foundation

extension Notification.Name {
    static let didOpenChat = Notification.Name("didOpenChat")
    static let didCloseChat = Notification.Name("didCloseChat")
}

extension Chat {
    private static var lastOpenedChatKey = "lastOpenedChat"

    static var lastOpenedChatSignal: ReadSignal<Int64?> {
        func getSignalValue() -> Int64? {
            if let lastOpenedChatDescription = UserDefaults.standard.string(forKey: lastOpenedChatKey) {
                return Int64(lastOpenedChatDescription)
            }

            return nil
        }

        let originalValue = getSignalValue()

        return Signal { callback in
            let bag = DisposeBag()

            bag += NotificationCenter.default.signal(forName: UserDefaults.didChangeNotification).onValue { _ in
                if getSignalValue() != originalValue {
                    callback(getSignalValue())
                }
            }

            return bag
        }.readable(capturing: getSignalValue())
    }

    private static func updateLastOpened() {
        let newValue = Date().currentTimeMillis()
        UserDefaults.standard.set(newValue, forKey: lastOpenedChatKey)
    }

    static func didOpen() {
        NotificationCenter.default.post(Notification(name: .didOpenChat))
        updateLastOpened()
    }

    static func didClose() {
        NotificationCenter.default.post(Notification(name: .didCloseChat))
        updateLastOpened()
    }
}
