import Foundation

public func delay(_ timeInterval: TimeInterval) async {
    try? await Task.sleep(for: .seconds(timeInterval))
}
