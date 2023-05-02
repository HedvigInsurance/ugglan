import Foundation
import Presentation
import hCore
import hCoreUI
import SwiftUI

public struct TravelInsuranceFlowJourney {

    public static func start() -> some JourneyPresentation {
        HostingJourney(TravelInsuranceStore.self,
                       rootView: ProgressView(),
                       style: .detented(.large)) { action in
            if case let .navigation(navigationAction) = action {
                if case .openTravelInsuranceForm = navigationAction {
                    TravelInsuranceFlowJourney.showForm()
                }
            }
        }.onPresent {
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            store.send(.getTravelInsuranceData)
        }
    }
    
    private static func showForm() -> some JourneyPresentation {
        HostingJourney(TravelInsuranceStore.self,
                       rootView: TravelInsuranceFormScreen())
        { action in
            if case let .navigation(navigationAction) = action {
                if case .openDatePicker = navigationAction {
                    ContinueJourney()
                }else if case let .openCoinsured(member) = navigationAction {
                    openCoinsured(member: member)
                }
            }
        }
        .hidesBackButton
        .addDismissClaimsFlow()
    }
    
    private static func openCoinsured(member: PolicyCoinsuredPersonModel?) -> some JourneyPresentation {
        HostingJourney(TravelInsuranceStore.self,
                       rootView: TravelInsuranceAddInsuredMemberScreen(member),
                       style: .detented(.scrollViewContentSize))
        { action in
            if case let .navigation(navigationAction) = action {
                if case .openDatePicker = navigationAction {
                    ContinueJourney()
                }
            }
        }
    }
}

extension JourneyPresentation {
    func addDismissClaimsFlow() -> some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody: L10n.Claims.Alert.body,
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}
