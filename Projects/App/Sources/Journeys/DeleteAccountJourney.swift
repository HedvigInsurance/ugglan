import Claims
import Contracts
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    static func deleteAccountJourney(details: MemberDetails) -> some JourneyPresentation {
        let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
        let contractsStore: ContractStore = globalPresentableStoreContainer.get()

        return HostingJourney(
            UgglanStore.self,
            rootView: DeleteAccountView(
                viewModel: DeleteAccountViewModel(
                    memberDetails: details,
                    claimsStore: claimsStore,
                    contractsStore: contractsStore
                )
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        ) { action in
            if action == .openChat {
                AppJourney.freeTextChat()
            } else if case .sendAccountDeleteRequest(let memberDetails) = action {
                AppJourney.sendAccountDeleteRequestJourney(details: memberDetails)
            } else if case .dismissScreen = action {
                PopJourney()
            }
        }
    }

    static func sendAccountDeleteRequestJourney(details: MemberDetails) -> some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: DeleteRequestLoadingView(screenState: .sendingMessage(details)),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
    }

    static var deleteRequestAlreadyPlacedJourney: some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: DeleteRequestLoadingView(screenState: .success),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
    }
}
