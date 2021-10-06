import Flow
import Foundation
import Presentation
import UIKit

public protocol Conditional { func condition() -> Bool }

public protocol FutureConditional { func condition() -> Future<Bool> }

extension UIViewController {
    internal enum ConditionalPresentation: Error { case conditionNotMet }

    public func presentConditionally<T: Conditional & Presentable, Value>(
        _ presentable: T,
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> T.Result where T.Result == Future<Value>, T.Matter == UIViewController {
        if presentable.condition() { return present(presentable, style: style, options: options) }

        return Future<Value> { completion in completion(.failure(ConditionalPresentation.conditionNotMet))
            return NilDisposer()
        }
    }

    public func presentConditionally<T: FutureConditional & Presentable, Value>(
        _ presentable: T,
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> T.Result where T.Result == Future<Value>, T.Matter == UIViewController {
        Future<Value> { completion in let bag = DisposeBag()

            bag += presentable.condition()
                .onValue { passed in
                    if passed {
                        bag += self.present(presentable, style: style, options: options)
                            .onResult(completion)
                    } else {
                        completion(.failure(ConditionalPresentation.conditionNotMet))
                    }
                }

            return bag
        }
    }
}
