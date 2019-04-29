//
//  DateFormatter+ISO8601.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-29.
//

import Foundation

extension DateFormatter {
    static var iso8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }
}
