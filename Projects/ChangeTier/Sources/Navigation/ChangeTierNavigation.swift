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
    let useOwnNavigation: Bool
    let router: Router

    //NOTE: Make sure to set it before moving to the ChangeTierLandingScreen
    var vm: ChangeTierViewModel!

    let changeTierContractsInput: ChangeTierContractsInput?

    init(
        router: Router?,
        vm: ChangeTierViewModel
    ) {
        self.router = router ?? Router()
        self.useOwnNavigation = router == nil
        self.vm = vm
        self.changeTierContractsInput = nil
    }

    init(
        changeTierContractsInput: ChangeTierContractsInput
    ) {
        if changeTierContractsInput.contracts.count == 1, let first = changeTierContractsInput.contracts.first {
            self.vm = .init(
                changeTierInput: .contractWithSource(
                    data: .init(source: changeTierContractsInput.source, contractId: first.contractId)
                )
            )
            self.changeTierContractsInput = nil
        } else {
            self.changeTierContractsInput = changeTierContractsInput
        }
        router = Router()
        self.useOwnNavigation = true
    }

    public static func getTiers(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {
        let client: ChangeTierClient = Dependencies.shared.resolve()
        let data = try await client.getTier(input: input)
        return data
    }

    func missingQuotesGoBackPressed() {
        if useOwnNavigation && changeTierContractsInput == nil {
            router.dismiss()
        } else {
            router.pop()
        }
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

    public init(
        source: ChangeTierSource,
        contractId: String
    ) {
        self.source = source
        self.contractId = contractId
    }

    let source: ChangeTierSource
    let contractId: String
}

public struct ChangeTierContractsInput: Equatable, Identifiable {
    public var id: String

    public init(
        source: ChangeTierSource,
        contracts: [ChangeTierContract]
    ) {
        self.id = "\(Date().timeIntervalSince1970)"
        self.source = source
        self.contracts = contracts
    }

    let source: ChangeTierSource
    let contracts: [ChangeTierContract]
}

public struct ChangeTierContract: Hashable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
    }
}

extension ChangeTierContract: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: ChangeTierContract.self)
    }
}

public enum ChangeTierSource {
    case changeTier
    case betterPrice
    case betterCoverage
}

public struct ChangeTierNavigation: View {
    @ObservedObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    public init(
        input: ChangeTierInput,
        router: Router? = nil
    ) {
        self.changeTierNavigationVm = .init(
            router: router,
            vm: .init(changeTierInput: input)
        )
    }

    public init(
        input: ChangeTierContractsInput
    ) {
        self.changeTierNavigationVm = .init(changeTierContractsInput: input)
    }

    public var body: some View {
        Group {
            if changeTierNavigationVm.useOwnNavigation {
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
                .configureTitle(
                    changeTierNavigationVm.vm.tiers.count == 1
                        ? L10n.tierFlowShowCoverageButton : L10n.tierFlowCompareButton
                )
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
        Group {
            if let changeTierContracts = changeTierNavigationVm.changeTierContractsInput {
                SelectInsuranceScreen(changeTierContractsInput: changeTierContracts)
                    .routerDestination(for: ChangeTierContract.self) { changeTierContract in
                        getScreen
                    }
            } else {
                getScreen
            }
        }
    }
    var getScreen: some View {

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
