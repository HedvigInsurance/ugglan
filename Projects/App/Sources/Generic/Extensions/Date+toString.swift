//
//  Date+toString.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-22.
//

import Foundation

extension Date {
    var localDateString: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
