import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct TravelInsuranceFlowJourney {

    public static func start() -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ProgressView(),
            style: .detented(.large)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openTravelInsuranceForm = navigationAction {
                    TravelInsuranceFlowJourney.showForm()
                }
            }
        }
        .onPresent {
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            store.send(.getTravelInsuranceData)
        }
    }
    
    private static func showForm() -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: TravelInsuranceFormScreen()
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case let .openDatePicker(type) = navigationAction {
                    openDatePicker(for: type)
                } else if case let .openCoinsured(member) = navigationAction {
                    openCoinsured(member: member)
                }
            }
        }
        .hidesBackButton
        .addDismissClaimsFlow()
    }
    
    
    private static func openDatePicker(for type: TravelInsuranceDatePickerType) -> some JourneyPresentation{
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        let selectedDate: Date? = {
            switch type {
            case .startDate:
                return store.state.travelInsuranceModel?.startDate
            case .endDate:
                return store.state.travelInsuranceModel?.endDate
            }
        }()
        let model = GeneralDatePickerViewModel(title: type.title,
                                               buttonTitle: L10n.generalContinueButton,
                                               minDate: store.state.travelInsuranceConfig?.minimumDate,
                                               maxDate: store.state.travelInsuranceConfig?.maximumDate,
                                               selectedDate: selectedDate,
                                               onDateSelected: { date in
            store.send(.setDate(value: date, type: type))
        })
        return HostingJourney(
            TravelInsuranceStore.self,
            rootView: GeneralDatePicker(model),
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]) { action in
                if case  .setDate = action {
                    PopJourney()
                }
                
            }.withDismissButton
    }
    
    private static func openCoinsured(member: PolicyCoinsuredPersonModel?) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: TravelInsuranceInsuredMemberScreen(member),
            style: .detented(.scrollViewContentSize)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openDatePicker = navigationAction {
                    ContinueJourney()
                }
            } else if case .setPolicyCoInsured = action {
                PopJourney()
            } else if case .removePolicyCoInsured = action {
                PopJourney()
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
