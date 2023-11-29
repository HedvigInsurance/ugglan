import Foundation

extension Date { public var currentTimeMillis: Int64 { Int64(timeIntervalSince1970 * 1000) } }
