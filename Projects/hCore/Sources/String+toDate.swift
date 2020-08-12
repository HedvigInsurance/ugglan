//
//  String-toDate.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-22.
//

import Foundation

extension String {
    // converts a YYYY-MM-DD date-string to a Date
    public var localDateToDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}
