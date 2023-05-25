import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct TravelInsuranceFlowJourney {
    
    public static func start(openChat: @escaping (() -> some JourneyPresentation)) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: TravelInsuranceLoadingView( onError: {
                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.send(.navigation(.openSomethingWentWrongScreen))
            }, .getTravelInsurance) {
                TravelInsuranceContractsScreen()
            },
            style: .detented(.large)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case let .openEmailScreen = navigationAction {
                    TravelInsuranceFlowJourney.showEmail()
                } else if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                } else if case .openSomethingWentWrongScreen = navigationAction {
                    openFailScreen(openChat: openChat)
                }
            }
        }
        .addDismissFlow()
        .onPresent {
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            store.send(.getTravelInsuranceData)
        }
    }
    
    private static func showEmail() -> some JourneyPresentation {
        let hosting = HostingJourney(
            TravelInsuranceStore.self,
            rootView: TravelInsuranceEmailScreen()) { action in
                if case let .navigation(navigationAction) = action {
                    if case .openTravelInsuranceForm = navigationAction {
                        TravelInsuranceFlowJourney.showForm()
                    }
                }
            }
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        if store.state.travelInsuranceConfigs == nil {
            return hosting
                .hidesBackButton
                .addDismissFlow()
        } else  {
            return hosting.addDismissFlow()
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
                } else if case let .openTravelInsurance(url, title) = navigationAction {
                    openDocument(url: url, title: title)
                }
            }
        }
        .addDismissFlow()
    }
    
    
    private static func openDatePicker(for type: TravelInsuranceDatePickerType) -> some JourneyPresentation{
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        let selectedDate: Date? = {
            switch type {
            case .startDate:
                return store.state.travelInsuranceModel?.startDate
            case .endDate:
                return nil
            }
        }()
        let model = GeneralDatePickerViewModel(title: type.title,
                                               buttonTitle: L10n.generalContinueButton,
                                               minDate: store.state.travelInsuranceConfig?.minStartDate,
                                               maxDate: store.state.travelInsuranceConfig?.maxStartDate,
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
                if case .dismissAddUpdateCoinsured = navigationAction {
                    PopJourney()
                }
            } else if case .setPolicyCoInsured = action {
                PopJourney()
            } else if case .removePolicyCoInsured = action {
                PopJourney()
            }
            
        }
    }
    
    private static func openFailScreen(openChat: @escaping (() -> some JourneyPresentation)) -> some JourneyPresentation {
        HostingJourney(TravelInsuranceStore.self,
                       rootView: TravelInsuranceFailScreen()) { action in
            if case let .navigation(navigationAction) = action {
                if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                }else if case .openFreeTextChat = navigationAction {
                    openChat()
                }
            }
        }.hidesBackButton
    }
    
    private static func openDocument(url: URL, title: String) -> some JourneyPresentation {
        Journey(
            Document(url: url, title: title, showDownloadButton: true)
        )
        .hidesBackButton
        .withJourneyDismissButton
        .disableModalInPresentation
    }
}

extension JourneyPresentation {
    func addDismissFlow() -> some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody: L10n.Claims.Alert.body,
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}
