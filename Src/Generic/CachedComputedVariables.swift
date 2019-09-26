//
//  CachedComputedVariables.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-26.
//

import Foundation
import Flow

class CachedComputedProperties {
    private let bag = DisposeBag()
    private var values: [String: Any]
    
    init(_ clearCacheSignal: Signal<Void>) {
        self.values = [:]
                
        bag += clearCacheSignal.with(weak: self).onValue { _, ´self´ in
            self.values = [:]
        }
    }
    
    func compute<Value>(_ key: String, _ getValue: @escaping () -> Value) -> Value {
        if let cachedValueCast = values[key] as? Value?, let cachedValue = cachedValueCast {
            return cachedValue
        }
                
        let value = getValue()
        
        self.values[key] = value
        
        return value
    }
}
