import Foundation

public extension Date {
    var currentTimeMillis: Int64 {
        Int64(timeIntervalSince1970 * 1000)
    }
}
