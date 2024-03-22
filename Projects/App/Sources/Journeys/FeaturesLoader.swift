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
                Task {
                    let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                    profileStore.send(.updateLanguage)
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    await contractStore.sendAsync(.fetchContracts)
                    await UIApplication.shared.appDelegate.setupFeatureFlags(onComplete: { success in
                        callback(())
                    })
                }
                return bag
            }
        )
    }
}
