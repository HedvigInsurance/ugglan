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

enum ChangeTierRouterActionsWithoutBackButton {
    case commitTier
}

extension ChangeTierRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary:
            return .init(describing: ChangeTierSummaryScreen.self)
        }
    }
}

extension ChangeTierRouterActionsWithoutBackButton: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .commitTier:
            return .init(describing: ChangeTierProcessingView.self)
        }
    }
}

public struct ChangeTierInput: Equatable, Identifiable {
    public var id: String {
        contractId
    }

    public init(source: ChangeTierSource, contractId: String) {
        self.source = source
        self.contractId = contractId
    }

    let source: ChangeTierSource
    let contractId: String
}

public enum ChangeTierSource {
    case changeTier
    case betterPrice
    case betterCoverage
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

    public init(
        input: ChangeTierInput
    ) {
        self.changeTierNavigationVm = .init(
            vm: .init(
                contractId: input.contractId,
                changeTierSource: input.source
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
                        ChangeTierSummaryScreen(
                            changeTierVm: changeTierNavigationVm.vm,
                            changeTierNavigationVm: changeTierNavigationVm
                        )
                        .configureTitle(L10n.offerUpdateSummaryTitle)
                        .withDismissButton()
                    }
                }
                .routerDestination(for: ChangeTierRouterActionsWithoutBackButton.self, options: [.hidesBackButton]) {
                    action in
                    switch action {
                    case .commitTier:
                        ChangeTierProcessingView(vm: changeTierNavigationVm.vm)
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
