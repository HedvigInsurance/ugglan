import Apollo
import Contracts
import Foundation
import Home
import MoveFlow
import Presentation
import hCore
import hCoreUI

extension JourneyPresentation {
    fileprivate var withCompletedToast: Self {
        onPresent {
            Toasts.shared
                .displayToast(
                    toast: Toast(
                        symbol: .icon(
                            hCoreUIAssets
                                .circularCheckmark
                                .image
                        ),
                        body: L10n
                            .movingFlowSuccessToast
                    )
                )
        }
    }
}

extension AppJourney {

    @JourneyBuilder
    static func movingFlow() -> some JourneyPresentation {
        MovingFlowJourneyNew.startMovingFlow { redirectType in
            switch redirectType {
            case .chat:
                AppJourney.freeTextChat().withDismissButton
            }
        }
        .onDismiss {
            let contractsStore: ContractStore = globalPresentableStoreContainer.get()
            contractsStore.send(.fetch)
        }
    }
}
