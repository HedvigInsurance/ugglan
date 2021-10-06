import Flow
import Foundation

extension Array {
    public var emitEachThenEnd: FiniteSignal<Element> {
        FiniteSignal { callback in
            self.forEach { element in
                callback(.value(element))
            }

            callback(.end)

            return NilDisposer()
        }
    }
}
