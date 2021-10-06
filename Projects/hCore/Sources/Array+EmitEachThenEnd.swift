//
//  Array+EmitEachThenEnd.swift
//  Array+EmitEachThenEnd
//
//  Created by Sam Pettersson on 2021-10-06.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Flow

extension Array {
    public var emitEachThenEnd: FiniteSignal<Element> {
        FiniteSignal { callback in
            self.forEach { element in
                callback(.value(element))
            }
            
            callback(.end)
            
            return NilDisposer()
        }
    }
}
