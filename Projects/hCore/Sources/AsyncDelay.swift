import Foundation

public func delay(_ timeInterval: TimeInterval) async {
    let delay = UInt64(timeInterval * 1_000 * 1_000 * 1_000)
    try? await Task.sleep(nanoseconds: delay)
}
