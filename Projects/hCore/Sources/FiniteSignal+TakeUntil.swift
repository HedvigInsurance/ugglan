import Flow
import Foundation

extension FiniteSignal {
    public func take(until readSignal: ReadSignal<Bool>) -> FiniteSignal<Value> {
        let bag = DisposeBag()
        return FiniteSignal { callback in
            bag += self.onValue { value in
                callback(.value(value))
            }

            bag += readSignal.onValue { shouldContinue in
                if !shouldContinue {
                    callback(.end)
                }
            }

            return bag
        }
    }
}
