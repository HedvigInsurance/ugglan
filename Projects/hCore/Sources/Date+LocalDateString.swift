//
//  Date+LocalDateString.swift
//  hCore
//
//  Created by sam on 2.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

extension Date {
    public var localDateString: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
