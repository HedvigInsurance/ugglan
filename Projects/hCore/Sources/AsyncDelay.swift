import Foundation

public func delay(_ timeInterval: TimeInterval) async {
    let delay = UInt64(timeInterval * 1000 * 1000 * 1000)
    try? await Task.sleep(nanoseconds: delay)
}
