import Flow
import Foundation
import Presentation
import UIKit

struct FeaturesLoader: Presentable {
    func materialize() -> (UIViewController, Signal<[UgglanState.Feature]>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                let store: UgglanStore = get()
                store.send(.fetchFeatures)

                bag += store.stateSignal.atOnce().compactMap { $0.features }
                    .onFirstValue { value in
                        callback(value)
                    }

                return bag
            }
        )
    }
}
