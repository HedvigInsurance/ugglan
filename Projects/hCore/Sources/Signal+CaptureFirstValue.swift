import Flow
import Foundation

extension Signal {
    public func captureFirstValue(
        onValue: @escaping (_ value: Value) -> Void
    ) -> CoreSignal<Kind.PotentiallyRead.DropReadWrite.DropReadWrite, Value> {
        self.buffer()
            .atValue { values in
                if values.count == 1, let value = values.first {
                    onValue(value)
                }
            }
            .filter { values in
                values.count > 1
            }
            .compactMap { $0.last }
    }
}
