import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct TravelInsuranceFlowJourney {

    @JourneyBuilder
    static func start(with specifications: [TravelInsuranceContractSpecification]) -> some JourneyPresentation {
        if specifications.count > 1 {
            showContractsList(for: specifications)
        } else if let specification = specifications.first {
            showStartDateScreen(specification: specification, style: .modally(presentationStyle: .fullScreen))
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

    private static func showContractsList(
        for specifications: [TravelInsuranceContractSpecification]
    ) -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: ContractsScreen(specifications: specifications)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case let .openStartDateScreen(specification) = navigationAction {
                    showStartDateScreen(specification: specification, style: .default)
                } else if case .dismissCreateTravelCertificate = navigationAction {
                    DismissJourney()
                }
            }
        }
        .addDismissFlow()
    }

    private static func showStartDateScreen(
        specification: TravelInsuranceContractSpecification,
        style: PresentationStyle
    ) -> some JourneyPresentation {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        store.startDateViewModel = StartDateViewModel(specification: specification)
        return HostingJourney(
            TravelInsuranceStore.self,
            rootView: StartDateScreen(vm: store.startDateViewModel!),
            style: style
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openWhoIsTravelingScreen = navigationAction {
                    showWhoIsTravelingScreen(specification: specification)
                }
            }
        }
        .addDismissFlow()
    }

    private static func showWhoIsTravelingScreen(
        specification: TravelInsuranceContractSpecification
    ) -> some JourneyPresentation {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        store.whoIsTravelingViewModel = WhoIsTravelingViewModel(specification: specification)
        return HostingJourney(
            TravelInsuranceStore.self,
            rootView: WhoIsTravelingScreen(vm: store.whoIsTravelingViewModel!)
        ) { action in
            if case let .navigation(navigationAction) = action {
                if case .openProcessingScreen = navigationAction {
                    openProcessingScreen()
                }
            } else if case .dismissTravelInsuranceFlow = action {
                DismissJourney()
            }
        }
        .addDismissFlow()

    }

    private static func openProcessingScreen() -> some JourneyPresentation {
        HostingJourney(
            TravelInsuranceStore.self,
            rootView: TravelCertificateProcessingScreen()
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
        return HostingJourney(
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
                } else if case let .openCreateNew(specifications) = navigationAction {
                    start(with: specifications)
                } else if case .goBack = navigationAction {
                    PopJourney()
                }
            } else if case .dismissTravelInsuranceFlow = action {
                DismissJourney()
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
