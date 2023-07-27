import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct TravelInsuranceFlowJourney {
    public static func getTravelCertificate() async throws -> TravelInsuranceSpecification {
        let disposeBag = DisposeBag()
        return try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<TravelInsuranceSpecification, Error>) -> Void in
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            store.send(.getTravelCertificateSpecification)
            let disposable = store.onAction(.travelCertificateSpecificationSet) {
                inCont.resume(returning: store.state.travelInsuranceConfigs!)
            }
            disposeBag.add(disposable)
        }
    }
    @JourneyBuilder
    public static func start(openChat: @escaping (() -> some JourneyPresentation)) -> some JourneyPresentation {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        let numberOfContracts = store.state.travelInsuranceConfigs?.travelCertificateSpecifications.count ?? 0
        if numberOfContracts > 1 {
            showContractsList(openChat)
        } else {
            showStartDateScreen(openChat, detended: true)
        }
    }

    private static func showContractsList(
        _ openChat: @escaping (() -> some JourneyPresentation)
    ) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ContractsScreen(),
            style: .modally(presentationStyle: .overFullScreen)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openStartDateScreen = navigationAction {
                    TravelInsuranceFlowJourney.showStartDateScreen(openChat, detended: false)
                } else if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                }
            }
        }
        .addDismissFlow()
    }

    private static func showStartDateScreen(
        _ openChat: @escaping (() -> some JourneyPresentation),
        detended: Bool
    ) -> some JourneyPresentation {
        let hosting = HostingJourney(
            TravelInsuranceStore.self,
            rootView: StartDateScreen(),
            style: detended ? .modally(presentationStyle: .overFullScreen) : .default
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openWhoIsTravelingScreen = navigationAction {
                    showWhoIsTravelingScreen(openChat)
                }
            }
        }
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        if store.state.travelInsuranceConfigs == nil {
            return hosting
                .hidesBackButton
                .addDismissFlow()
        } else {
            return hosting.addDismissFlow()
        }

    }

    private static func showWhoIsTravelingScreen(
        _ openChat: @escaping (() -> some JourneyPresentation)
    ) -> some JourneyPresentation {
        let hosting = HostingJourney(
            TravelInsuranceStore.self,
            rootView: WhoIsTravelingScreen()
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openProcessingScreen = navigationAction {
                    openProcessingScreen(openChat)
                } else if case let .openCoinsured(member) = navigationAction {
                    openCoinsured(member: member)
                }
            }
        }
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        if store.state.travelInsuranceConfigs == nil {
            return hosting
                .hidesBackButton
                .addDismissFlow()
        } else {
            return hosting.addDismissFlow()
        }

    }

    private static func openCoinsured(member: PolicyCoinsuredPersonModel?) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: InsuredMemberScreen(member),
            style: .detented(.scrollViewContentSize)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .dismissAddUpdateCoinsured = navigationAction {
                    PopJourney()
                }
            } else if case .setPolicyCoInsured = action {
                PopJourney()
            } else if case .updatePolicyCoInsured = action {
                PopJourney()
            } else if case .removePolicyCoInsured = action {
                PopJourney()
            }
        }
    }

    private static func openProcessingScreen(
        _ openChat: @escaping (() -> some JourneyPresentation)
    ) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ProcessingScreen()
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                } else if case .openFreeTextChat = navigationAction {
                    openChat()
                }
            }
        }
        .hidesBackButton
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
