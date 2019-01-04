//
//  DynamicString.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-05.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import UIKit

struct DynamicString: SignalProvider {
    var providedSignal = ReadWriteSignal<String>("")
    
    var value: String {
        get {
            return providedSignal.value
        }
        set(newValue) {
            providedSignal.value = newValue
        }
    }
    
    init(_ value: String) {
        self.value = value
    }
}

extension UILabel {
    func setDynamicText(_ dynamicText: DynamicString) -> Disposable {
        let bag = DisposeBag()
        text = dynamicText.value
        
        bag += dynamicText.onValue { newValue in
            self.text = newValue
        }
        
        return bag
    }
}
