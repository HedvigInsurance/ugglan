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
                if let travelInsuranceConfigs = store.state.travelInsuranceConfigs {
                    inCont.resume(returning: travelInsuranceConfigs)
                } else {
                    inCont.resume(throwing: NetworkError.badRequest(message: nil))
                }
            }
            disposeBag.add(disposable)
        }
    }
    @JourneyBuilder
    public static func start() -> some JourneyPresentation {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        let numberOfContracts = store.state.travelInsuranceConfigs?.travelCertificateSpecifications.count ?? 0
        if numberOfContracts > 1 {
            showContractsList()
        } else {
            showStartDateScreen(detended: true)
        }
    }

    @JourneyBuilder
    public static func list() -> some JourneyPresentation {
        showListScreen()
    }

    private static func showContractsList() -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ContractsScreen(),
            style: .modally(presentationStyle: .overFullScreen)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openStartDateScreen = navigationAction {
                    TravelInsuranceFlowJourney.showStartDateScreen(detended: false)
                } else if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                }
            }
        }
        .addDismissFlow()
    }

    private static func showStartDateScreen(detended: Bool) -> some JourneyPresentation {
        let hosting = HostingJourney(
            TravelInsuranceStore.self,
            rootView: StartDateScreen(),
            style: detended ? .modally(presentationStyle: .overFullScreen) : .default
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openWhoIsTravelingScreen = navigationAction {
                    showWhoIsTravelingScreen()
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

    private static func showWhoIsTravelingScreen() -> some JourneyPresentation {
        let hosting = HostingJourney(
            TravelInsuranceStore.self,
            rootView: WhoIsTravelingScreen()
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openProcessingScreen = navigationAction {
                    openProcessingScreen()
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
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar]
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

    private static func openProcessingScreen() -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ProcessingScreen()
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                } else if case .goBack = navigationAction {
                    PopJourney()
                }
            }
        }
        .hidesBackButton
    }

    private static func showListScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: ListScreen()
        )
        .configureTitle(L10n.TravelCertificate.cardTitle)
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
