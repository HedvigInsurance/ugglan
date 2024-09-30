import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class ChangeTierNavigationViewModel: ObservableObject {
    @Published public var isEditTierPresented = false
    @Published public var isEditDeductiblePresented = false
    @Published public var isCompareTiersPresented = false
    @Published public var isInsurableLimitPresented: InsurableLimits?
    @Published public var document: Document?

    let router = Router()
    var vm: ChangeTierViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
    }
}

enum ChangeTierRouterActions {
    case summary
}

extension ChangeTierRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary:
            return "Change tier summary"
        }
    }
}

public enum ChangeTierSource {
    case changeTier
    case betterPrice
    case betterCoverage
    case moving
}

public struct ChangeTierNavigation: View {
    @ObservedObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    public init(
        contractId: String,
        changeTierSource: ChangeTierSource
    ) {
        self.changeTierNavigationVm = .init(
            vm: .init(
                contractId: contractId,
                changeTierSource: changeTierSource
            )
        )
    }

    public var body: some View {
        RouterHost(
            router: changeTierNavigationVm.router,
            options: [],
            tracking: ChangeTierTrackingType.changeTierLandingScreen
        ) {
            ChangeTierLandingScreen(vm: changeTierNavigationVm.vm)
                .withDismissButton()
                .routerDestination(for: ChangeTierRouterActions.self) { action in
                    switch action {
                    case .summary:
                        ChangeTierSummaryScreen(vm: changeTierNavigationVm.vm)
                            .configureTitle("Summary")
                    }
                }
        }
        .environmentObject(changeTierNavigationVm)
        .detent(
            presented: $changeTierNavigationVm.isEditTierPresented,
            style: [.height]
        ) {
            EditTierScreen(vm: changeTierNavigationVm.vm)
                .embededInNavigation(options: .navigationType(type: .large), tracking: ChangeTierTrackingType.editTier)
                .environmentObject(changeTierNavigationVm)
        }
        .detent(
            presented: $changeTierNavigationVm.isEditDeductiblePresented,
            style: [.height]
        ) {
            EditDeductibleScreen(vm: changeTierNavigationVm.vm)
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: ChangeTierTrackingType.editDeductible
                )
                .environmentObject(changeTierNavigationVm)
        }
        .detent(
            item: $changeTierNavigationVm.isInsurableLimitPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { insurableLimit in
            InfoView(
                title: L10n.contractCoverageMoreInfo,
                description: insurableLimit.description
            )
        }
        .modally(presented: $changeTierNavigationVm.isCompareTiersPresented) {
            CompareTierScreen(vm: changeTierNavigationVm.vm)
                .configureTitle(L10n.tierFlowCompareButton)
                .withDismissButton()
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: ChangeTierTrackingType.compareTier
                )
                .environmentObject(changeTierNavigationVm)
        }
        .detent(
            item: $changeTierNavigationVm.document,
            style: [.large]
        ) { document in
            PDFPreview(document: .init(url: document.url, title: document.title))
        }
    }
}

private enum ChangeTierTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .changeTierLandingScreen:
            return .init(describing: ChangeTierLandingScreen.self)
        case .editTier:
            return .init(describing: EditTierScreen.self)
        case .editDeductible:
            return .init(describing: EditDeductibleScreen.self)
        case .compareTier:
            return .init(describing: CompareTierScreen.self)
        }
    }

    case changeTierLandingScreen
    case editTier
    case editDeductible
    case compareTier
}
