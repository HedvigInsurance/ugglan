import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import Claims
import Contracts
import hGraphQL

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
            } else if case .sendAccountDeleteRequest(let memberDetails) = action {
                AppJourney.sendAccountDeleteRequestJourney(details: memberDetails)
            }
        }
        .setStyle(.detented(.large))
        .withJourneyDismissButton
    }
    
    static func sendAccountDeleteRequestJourney(details: MemberDetails) -> some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: DeleteRequestLoadingView(memberDetails: details),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            // TODO: Create a store and actions for AccountDeletion
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
    }
    
}
