import Claims
import Contracts
import Flow
import Foundation
import Presentation
import Profile
import SwiftUI
import hCore
import hCoreUI

struct ExperimentsLoader: Presentable {
    func materialize() -> (UIViewController, Signal<Void>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                profileStore.send(.updateLanguage)
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)
                bag += contractStore.actionSignal
                    .onValue { action in
                        if case .fetchCompleted = action {
                            UIApplication.shared.appDelegate.setupFeatureFlags(onComplete: { success in
                                callback(())
                            })
                            bag.dispose()
                        }
                    }
                return bag
            }
        )
    }
}
