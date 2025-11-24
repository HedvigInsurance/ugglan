import Addons
import Contracts
import EditCoInsured
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class TravelCertificateNavigationViewModel: ObservableObject {
    public init() {}
    @Published var isDocumentPresented: TravelCertificateModel?
    @Published var isStartDateScreenPresented: TravelInsuranceSpecificationNavigationModel?
    @Published var isAddonPresented: ChangeAddonInput?
    @Published var isInfoViewPresented = false

    var startDateViewModel: StartDateViewModel?
    var whoIsTravelingViewModel: WhoIsTravelingViewModel?

    public var editCoInsuredVm = EditCoInsuredViewModel(
        existingCoInsured: globalPresentableStoreContainer.get(of: ContractStore.self)
    )
}

struct TravelInsuranceSpecificationNavigationModel: Hashable, Identifiable {
    var id: String?
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
            return .init(describing: TravelCertificatesListScreen.self)
        }
    }
}

enum TravelCertificateRouterActionsWithoutBackButton: Hashable {
    case processingScreen
    case startScreen
}

extension TravelCertificateRouterActionsWithoutBackButton: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .processingScreen:
            return .init(describing: TravelCertificateProcessingScreen.self)
        case .startScreen:
            return ""
        }
    }
}

public struct TravelCertificateNavigation: View {
    @ObservedObject var vm: TravelCertificateNavigationViewModel
    @StateObject var router = Router()
    @StateObject var createNewRouter = Router()

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
                infoButtonPlacement: infoButtonPlacement
            )
        } else {
            showListScreen(
                infoButtonPlacement: infoButtonPlacement
            )
            .withDismissButton()
        }
    }

    public var body: some View {
        Group {
            if useOwnNavigation {
                RouterHost(
                    router: router,
                    options: .extendedNavigationWidth,
                    tracking: TravelCertificateRouterActions.list(specifications: [])
                ) {
                    getListScreen
                }
            } else {
                getListScreen
            }
        }
        .environmentObject(vm)
        .detent(
            item: $vm.isDocumentPresented,
            transitionType: .detent(style: [.large]),
            options: .constant(.withoutGrabber)
        ) { model in
            PDFPreview(
                document: .init(displayName: model.title, url: model.url.absoluteString, type: .unknown)
            )
        }
        .detent(
            presented: $vm.isInfoViewPresented,

            options: .constant(.withoutGrabber)
        ) {
            InfoView(
                title: L10n.TravelCertificate.Info.title,
                description: L10n.TravelCertificate.Info.subtitle
            )
        }
        .modally(
            item: $vm.isAddonPresented,
            options: .constant(.withoutGrabber)
        ) { addonInput in
            ChangeAddonNavigation(input: addonInput)
        }
        .modally(
            item: $vm.isStartDateScreenPresented,
            tracking: TravelCertificateRouterActionsWithoutBackButton.startScreen
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
                    case .startScreen:
                        EmptyView()
                    }
                }
                .embededInNavigation(
                    router: createNewRouter,
                    options: .extendedNavigationWidth,
                    tracking: specificationModel.specification.count > 1
                        ? TravelCertificateRouterActions.list(specifications: specificationModel.specification)
                        : TravelCertificateRouterActions.startDate(
                            specification: specificationModel.specification.first!
                        )
                )
        }
    }

    private func showListScreen(
        infoButtonPlacement: ListToolBarPlacement
    ) -> some View {
        TravelCertificatesListScreen(
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
        TravelCertificateSelectInsuranceScreen(
            router: createNewRouter,
            specifications: specifications
        )
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
        vm.whoIsTravelingViewModel = WhoIsTravelingViewModel(specification: specification, router: createNewRouter)
        return WhoIsTravelingScreen(
            vm: vm.whoIsTravelingViewModel!,
            travelCertificateNavigationVm: vm
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
        withAlertDismiss()
    }
}
