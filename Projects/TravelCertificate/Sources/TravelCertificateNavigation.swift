import EditCoInsuredShared
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

    public var editCoInsuredVm = EditCoInsuredViewModel()
}

struct TravelInsuranceSpecificationNavigationModel: Hashable, Identifiable {
    public var id: String?
    let specification: [TravelInsuranceContractSpecification]
}

enum TravelCertificateRouterActions: Hashable {
    case whoIsTravelling(specifiction: TravelInsuranceContractSpecification)
    case startDate(specification: TravelInsuranceContractSpecification)
    case list(specifications: [TravelInsuranceContractSpecification])
}

extension TravelCertificateRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .whoIsTravelling:
            return .init(describing: WhoIsTravelingScreen.self)
        case .startDate:
            return .init(describing: StartDateScreen.self)
        case .list:
            return .init(describing: ContractsScreen.self)
        }
    }

}

enum TravelCertificateRouterActionsWithoutBackButton: Hashable {
    case processingScreen
}

extension TravelCertificateRouterActionsWithoutBackButton: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .processingScreen:
            return .init(describing: TravelCertificateProcessingScreen.self)
        }
    }

}

public enum ListToolBarPlacement {
    case trailing
    case leading
}

public struct TravelCertificateNavigation: View {
    @ObservedObject var vm: TravelCertificateNavigationViewModel
    @StateObject var router = Router()
    private var infoButtonPlacement: ListToolBarPlacement
    private let useOwnNavigation: Bool

    public init(
        vm: TravelCertificateNavigationViewModel,
        infoButtonPlacement: ListToolBarPlacement,
        useOwnNavigation: Bool
    ) {
        self.vm = vm
        self.infoButtonPlacement = infoButtonPlacement
        self.useOwnNavigation = useOwnNavigation
    }

    @ViewBuilder
    private var getListScreen: some View {
        if infoButtonPlacement == .trailing {
            showListScreen(
                infoButtonPlacement: .topBarTrailing
            )
        } else {
            showListScreen(
                infoButtonPlacement: .topBarLeading
            )
            .withDismissButton()
        }
    }

    public var body: some View {
        Group {
            if useOwnNavigation {
                RouterHost(router: router, tracking: TravelCertificateRouterActions.list(specifications: [])) {
                    getListScreen
                }
            } else {
                getListScreen
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
                    case let .list(specifications):
                        showContractsList(for: specifications)
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
                .embededInNavigation(
                    tracking: specificationModel.specification.count > 1
                        ? TravelCertificateRouterActions.list(specifications: specificationModel.specification)
                        : TravelCertificateRouterActions.startDate(
                            specification: specificationModel.specification.first!
                        )
                )
        }
    }

    private func showListScreen(
        infoButtonPlacement: ToolbarItemPlacement
    ) -> some View {
        ListScreen(
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
            vm: vm.whoIsTravelingViewModel!
        )
        .environmentObject(vm)
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
