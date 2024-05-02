import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class TravelCertificateNavigationViewModel: ObservableObject {
    public init() {}
    @Published var isDocumentPresented: TravelCertificateModel?
    var startDateViewModel: StartDateViewModel?
    var whoIsTravelingViewModel: WhoIsTravelingViewModel?
}

struct TravelInsuranceSpecificationNavigationModel: Hashable {
    public var id: String?
    let specification: [TravelInsuranceContractSpecification]
}

enum TravelCertificateRouterActions: Hashable {
    case whoIsTravelling(specifiction: TravelInsuranceContractSpecification)
}

enum TravelCertificateRouterActionsWithoutBackButton: Hashable {
    case processingScreen
}

public enum ListToolBarPlacement {
    case trailing
    case leading
}

public struct TravelCertificateNavigation: View {
    @StateObject private var vm = TravelCertificateNavigationViewModel()
    @StateObject var router = Router()
    private var canCreateTravelInsurance: Bool
    private var infoButtonPlacement: ListToolBarPlacement
    private var openCoInsured: () -> Void

    public init(
        canCreateTravelInsurance: Bool,
        infoButtonPlacement: ListToolBarPlacement,
        openCoInsured: @escaping () -> Void
    ) {
        self.canCreateTravelInsurance = canCreateTravelInsurance
        self.infoButtonPlacement = infoButtonPlacement
        self.openCoInsured = openCoInsured
    }

    @ViewBuilder
    private var getListScreen: some View {
        if infoButtonPlacement == .trailing {
            showListScreen(
                canAddTravelInsurance: canCreateTravelInsurance,
                infoButtonPlacement: .topBarTrailing
            )
            .embededInNavigation()
        } else {
            showListScreen(
                canAddTravelInsurance: canCreateTravelInsurance,
                infoButtonPlacement: .topBarLeading
            )
            .withDismissButton()
        }
    }

    public var body: some View {
        RouterHost(router: router) {
            getListScreen
                .routerDestination(for: TravelInsuranceSpecificationNavigationModel.self) { specificationModel in
                    start(with: specificationModel.specification)
                }
                .routerDestination(for: TravelInsuranceContractSpecification.self) { specification in
                    showStartDateScreen(specification: specification)
                }
                .routerDestination(for: TravelCertificateRouterActions.self) { action in
                    switch action {
                    case let .whoIsTravelling(specification):
                        showWhoIsTravelingScreen(specification: specification)
                    }
                }
                .routerDestination(
                    for: TravelCertificateRouterActionsWithoutBackButton.self,
                    options: .hidesBackButton
                ) { action in
                    switch action {
                    case .processingScreen:
                        openProcessingScreen()
                    }
                }
        }
        .environmentObject(vm)
        .detent(
            item: $vm.isDocumentPresented,
            style: .large,
            options: .constant(.withoutGrabber)
        ) { model in
            PDFPreview(
                document: .init(url: model.url, title: model.title)
            )
        }
    }

    private func showListScreen(
        canAddTravelInsurance: Bool,
        infoButtonPlacement: ToolbarItemPlacement
    ) -> some View {
        ListScreen(
            canAddTravelInsurance: canAddTravelInsurance,
            infoButtonPlacement: infoButtonPlacement
        )
        .configureTitle(L10n.TravelCertificate.cardTitle)
    }

    @ViewBuilder
    private func start(with specifications: [TravelInsuranceContractSpecification]) -> some View {
        if specifications.count > 1 {
            showContractsList(for: specifications)
        } else if let specification = specifications.first {
            showStartDateScreen(specification: specification)
        }
    }

    private func showContractsList(
        for specifications: [TravelInsuranceContractSpecification]
    ) -> some View {
        ContractsScreen(specifications: specifications)
            .addDismissFlow()
    }

    private func showStartDateScreen(
        specification: TravelInsuranceContractSpecification
    ) -> some View {
        vm.startDateViewModel = StartDateViewModel(specification: specification)
        return StartDateScreen(vm: vm.startDateViewModel!)
            .addDismissFlow()
    }

    private func showWhoIsTravelingScreen(
        specification: TravelInsuranceContractSpecification
    ) -> some View {
        vm.whoIsTravelingViewModel = WhoIsTravelingViewModel(specification: specification)
        return WhoIsTravelingScreen(
            vm: vm.whoIsTravelingViewModel!,
            openCoInsured: {
                openCoInsured()
            }
        )
        .addDismissFlow()
    }

    private func openProcessingScreen() -> some View {
        TravelCertificateProcessingScreen()
            .environmentObject(vm.whoIsTravelingViewModel!)
            .environmentObject(vm.startDateViewModel!)
    }
}

extension View {
    func addDismissFlow() -> some View {
        self.withDismissButton(
            title: L10n.General.areYouSure,
            message: L10n.Claims.Alert.body,
            confirmButton: L10n.General.yes,
            cancelButton: L10n.General.no
        )
    }
}
