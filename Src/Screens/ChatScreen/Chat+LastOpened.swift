//
//  Chat+LastOpened.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-08.
//

import Foundation
import Flow

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
            
            bag += NotificationCenter.default.signal(forName: UserDefaults.didChangeNotification).onValue { notification in
                if getSignalValue() != originalValue {
                    callback(getSignalValue())
                }
            }
            
            return bag
            }.readable(capturing: getSignalValue())
    }
    
    static func didOpen() {
        let newValue = Date().currentTimeMillis()
        UserDefaults.standard.set(newValue, forKey: lastOpenedChatKey)
    }
}
