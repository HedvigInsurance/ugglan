//
//  FeaturesLoader.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-26.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow
import Presentation

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
