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

    let vm: ChangeTierViewModel
    let router: Router
    init(
        router: Router,
        vm: ChangeTierViewModel
    ) {
        self.router = router
        self.vm = vm
    }

    public static func getTiers(input: ChangeTierInputData) async throws(ChangeTierError) -> ChangeTierIntentModel {
        let client: ChangeTierClient = Dependencies.shared.resolve()
        let data = try await client.getTier(input: input)
        return data
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

public enum ChangeTierInput: Identifiable, Equatable {
    public var id: String {
        return UUID().uuidString
    }
    public static func == (lhs: ChangeTierInput, rhs: ChangeTierInput) -> Bool {
        return lhs.id != rhs.id
    }
    case contractWithSource(data: ChangeTierInputData)
    case existingIntent(intent: ChangeTierIntentModel, onSelect: ((Tier, Deductible)) -> Void)
}
public struct ChangeTierInputData: Equatable, Identifiable {
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
    private let useOwnNavigation: Bool
    public init(
        input: ChangeTierInput,
        router: Router? = nil
    ) {
        self.changeTierNavigationVm = .init(
            router: router ?? Router(),
            vm: .init(changeTierInput: input)
        )
        useOwnNavigation = router == nil
    }

    public var body: some View {
        Group {
            if useOwnNavigation {
                RouterHost(
                    router: changeTierNavigationVm.router,
                    options: [],
                    tracking: ChangeTierTrackingType.changeTierLandingScreen
                ) {
                    wrapperHost
                }
            } else {
                wrapperHost
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

    private var wrapperHost: some View {
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
