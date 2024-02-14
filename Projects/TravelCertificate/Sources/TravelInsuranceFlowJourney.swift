import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct TravelInsuranceFlowJourney {
    static func getTravelCertificate() async throws -> TravelInsuranceSpecification {
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
    static func start() -> some JourneyPresentation {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        let numberOfContracts = store.state.travelInsuranceConfigs?.travelCertificateSpecifications.count ?? 0
        if numberOfContracts > 1 {
            showContractsList()
        } else {
            showStartDateScreen(style: .modally(presentationStyle: .fullScreen))
        }
    }

    @JourneyBuilder
    public static func list(
        canAddTravelInsurance: Bool,
        style: PresentationStyle,
        infoButtonPlacement: ToolbarItemPlacement
    ) -> some JourneyPresentation {
        showListScreen(
            canAddTravelInsurance: canAddTravelInsurance,
            style: style,
            infoButtonPlacement: infoButtonPlacement
        )
    }

    private static func showContractsList() -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ContractsScreen(),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openStartDateScreen = navigationAction {
                    showStartDateScreen(style: .default)
                } else if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                }
            }
        }
        .addDismissFlow()
    }

    private static func showStartDateScreen(style: PresentationStyle) -> some JourneyPresentation {
        let hosting = HostingJourney(
            TravelInsuranceStore.self,
            rootView: StartDateScreen(),
            style: style
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
                }
            } else if case .goToDeepLink = action {
                DismissJourney()
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

    private static func showListScreen(
        canAddTravelInsurance: Bool,
        style: PresentationStyle,
        infoButtonPlacement: ToolbarItemPlacement
    ) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ListScreen(
                canAddTravelInsurance: canAddTravelInsurance,
                infoButtonPlacement: infoButtonPlacement
            ),
            style: style,
            options: [.largeNavigationBar, .dismissOnlyTopPresentedViewController]
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case let .openDetails(model) = navigationAction {
                    showDetails(for: model)
                } else if case .openCreateNew = navigationAction {
                    start()
                } else if case .goBack = navigationAction {
                    PopJourney()
                }
            }
        }
        .configureTitle(L10n.TravelCertificate.cardTitle)
    }

    private static func showDetails(for model: TravelCertificateModel) -> some JourneyPresentation {
        let document = Document(url: model.url, title: model.title)
        return Journey(
            document,
            style: .detented(.large)
        )
        .withDismissButton
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
