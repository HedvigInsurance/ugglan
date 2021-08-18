import Flow
import Foundation

extension CoreSignal where Value == String? {
    public func toInt() -> CoreSignal<Kind.DropWrite, Int?> {
        map { amount -> Int? in if let amount = amount, let double = Double(amount) { return Int(double) }

            return nil
        }
    }
}
