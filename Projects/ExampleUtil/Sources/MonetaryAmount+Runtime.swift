//
//  MonetaryAmount+Runtime.swift
//  ForeverExample
//
//  Created by sam on 15.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import Runtime

extension MonetaryAmount: DefaultConstructor {
    public init() {
        self = MonetaryAmount(amount: "10.0", currency: "SEK")
    }
}
