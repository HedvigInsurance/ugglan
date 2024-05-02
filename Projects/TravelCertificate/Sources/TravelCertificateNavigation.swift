import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class TravelCertificateNavigationViewModel: ObservableObject {
    public init() {}
    @Published var isDocumentPresented: TravelCertificateModel?
    @Published var isStartDateScreenPresented: TravelInsuranceSpecificationNavigationModel?

    var startDateViewModel: StartDateViewModel?
    var whoIsTravelingViewModel: WhoIsTravelingViewModel?
}

struct TravelInsuranceSpecificationNavigationModel: Hashable, Identifiable {
    public var id: String?
    let specification: [TravelInsuranceContractSpecification]
}

enum TravelCertificateRouterActions: Hashable {
    case whoIsTravelling(specifiction: TravelInsuranceContractSpecification)
    case startDate(specification: TravelInsuranceContractSpecification)
}

enum TravelCertificateRouterActionsWithoutBackButton: Hashable {
    case processingScreen
}

public struct TravelCertificateNavigation: View {
    @StateObject private var vm = TravelCertificateNavigationViewModel()
    @StateObject var router = Router()
    private let infoButtonPlacement: ToolbarItemPlacement
    private let openCoInsured: () -> Void

    public init(
        infoButtonPlacement: ToolbarItemPlacement,
        openCoInsured: @escaping () -> Void
    ) {
        self.infoButtonPlacement = infoButtonPlacement
        self.openCoInsured = openCoInsured
    }

    public var body: some View {
        RouterHost(router: router) {
            showListScreen(
                infoButtonPlacement: infoButtonPlacement
            )
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
        .fullScreenCover(
            item: $vm.isStartDateScreenPresented
        ) { specificationModel in
            start(with: specificationModel.specification)
                .routerDestination(for: TravelCertificateRouterActions.self) { action in
                    switch action {
                    case let .whoIsTravelling(specification):
                        showWhoIsTravelingScreen(specification: specification)
                    case let .startDate(specification):
                        showStartDateScreen(specification: specification)
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
                .embededInNavigation()
                .addDismissFlow()
        }
    }

    private func showListScreen(
        infoButtonPlacement: ToolbarItemPlacement
    ) -> some View {
        ListScreen(
            infoButtonPlacement: infoButtonPlacement
        )
        .withDismissButton()
        .configureTitle(L10n.TravelCertificate.cardTitle)
    }

    @ViewBuilder
    private func start(with specifications: [TravelInsuranceContractSpecification]) -> some View {
        if specifications.count > 1 {
            /* TODO: CHANGE TO PUSH? */
            showContractsList(for: specifications)
        } else if let specification = specifications.first {
            showStartDateScreen(specification: specification)
                .addDismissFlow()
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
