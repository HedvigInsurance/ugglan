import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import Claims
import Contracts

extension AppJourney {
    static var deleteAccountJourney: some JourneyPresentation {
        let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
        let contractsStore: ContractStore = globalPresentableStoreContainer.get()
        
        return HostingJourney(
            UgglanStore.self,
            rootView: DeleteAccountView(
                viewModel: DeleteAccountViewModel(
                    claimsStore: claimsStore,
                    contractsStore: contractsStore
                )
            )
        ) { action in
            if action == .openChat {
                AppJourney.freeTextChat()
            }
        }
        .setStyle(.detented(.large))
        .withJourneyDismissButton
    }
}
