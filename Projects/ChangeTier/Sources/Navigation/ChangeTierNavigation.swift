import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChangeTierNavigationViewModel: ObservableObject {
    @Published public var isEditTierPresented: EditTypeModel?
    @Published public var isCompareTiersPresented = false
    @Published public var isInsurableLimitPresented: InsurableLimits?
    @Published public var document: hPDFDocument?
    @Published public var isInfoViewPresented: InfoViewDataModel? = nil
    let useOwnNavigation: Bool
    let router: NavigationRouter

    // NOTE: Make sure to set it before moving to the ChangeTierLandingScreen
    var vm: ChangeTierViewModel!

    let changeTierContractsInput: ChangeTierContractsInput?

    init(
        router: NavigationRouter?,
        vm: ChangeTierViewModel
    ) {
        self.router = router ?? NavigationRouter()
        useOwnNavigation = router == nil
        self.vm = vm
        changeTierContractsInput = nil
    }

    init(
        changeTierContractsInput: ChangeTierContractsInput
    ) {
        if changeTierContractsInput.contracts.count == 1, let first = changeTierContractsInput.contracts.first {
            vm = .init(
                changeTierInput: .contractWithSource(
                    data: .init(source: changeTierContractsInput.source, contractId: first.contractId)
                )
            )
            self.changeTierContractsInput = nil
        } else {
            self.changeTierContractsInput = changeTierContractsInput
        }
        router = NavigationRouter()
        useOwnNavigation = true
    }

    public static func getTiers(input: ChangeTierInputData) async throws -> ChangeTierIntentModelState {
        let service = ChangeTierService()
        let data = try await service.getTier(input: input)
        return data
    }

    func missingQuotesGoBackPressed() {
        if useOwnNavigation, changeTierContractsInput == nil {
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
        switch self {
        case let .contractWithSource(data):
            return data.contractId + data.source.asString
        case let .existingIntent(intent, _):
            return intent.displayName + intent.tiers.flatMap(\.quotes).compactMap(\.id).joined(separator: ",")
        }
    }

    public static func == (lhs: ChangeTierInput, rhs: ChangeTierInput) -> Bool {
        lhs.id == rhs.id
    }

    case contractWithSource(data: ChangeTierInputData)
    case existingIntent(intent: ChangeTierIntentModel, onSelect: (((Tier, Quote)) -> Void)?)
}

public struct ChangeTierInputData: Equatable, Identifiable, Codable {
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

    public let source: ChangeTierSource
    public let contractId: String
}

public struct ChangeTierContractsInput: Equatable, Identifiable {
    public var id: String

    public init(
        source: ChangeTierSource,
        contracts: [ChangeTierContract]
    ) {
        id = "\(Date().timeIntervalSince1970)"
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
        .init(describing: ChangeTierContract.self)
    }
}

public enum ChangeTierSource: Codable {
    case changeTier
    case betterPrice
    case betterCoverage
}

public struct ChangeTierNavigation: View {
    @StateObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    public init(
        input: ChangeTierInput,
        dataProvider: ChangeTierQuoteDataProvider? = nil,
        router: NavigationRouter? = nil
    ) {
        _changeTierNavigationVm = StateObject(
            wrappedValue: .init(
                router: router,
                vm: .init(
                    changeTierInput: input,
                    dataProvider: dataProvider
                )
            )
        )
    }

    public init(
        input: ChangeTierContractsInput
    ) {
        _changeTierNavigationVm = StateObject(
            wrappedValue: .init(
                changeTierContractsInput: input
            )
        )
    }

    public var body: some View {
        Group {
            if changeTierNavigationVm.useOwnNavigation {
                hNavigationStack(
                    router: changeTierNavigationVm.router,
                    options: .extendedNavigationWidth,
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
            item: $changeTierNavigationVm.isEditTierPresented
        ) { model in
            EditScreen(
                selectedItem: model.selectedItem,
                vm: changeTierNavigationVm.vm,
                type: model.type
            )
            .embededInNavigation(
                options: .navigationType(type: .large),
                tracking: ChangeTierTrackingType.edit(type: model.type)
            )
            .environmentObject(changeTierNavigationVm)
        }
        .detent(
            item: $changeTierNavigationVm.isInsurableLimitPresented,

            options: .constant(.alwaysOpenOnTop)
        ) { insurableLimit in
            InfoView(
                title: insurableLimit.label,
                description: insurableLimit.description
            )
        }
        .modally(presented: $changeTierNavigationVm.isCompareTiersPresented) {
            CompareTierScreen(
                vm: .init(
                    tiers: changeTierNavigationVm.vm.tiers
                )
            )
            .withDismissButton()
            .embededInNavigation(
                options: .extendedNavigationWidth,
                tracking: ChangeTierTrackingType.compareTier
            )
            .environmentObject(changeTierNavigationVm)
        }
        .detent(
            item: $changeTierNavigationVm.document,
            transitionType: .detent(style: [.large])
        ) { document in
            PDFPreview(document: document)
        }
        .detent(
            item: $changeTierNavigationVm.isInfoViewPresented,
            transitionType: .detent(style: [.height])
        ) { info in
            InfoView(
                title: info.title ?? "",
                description: info.description ?? ""
            )
        }
    }

    private var wrapperHost: some View {
        Group {
            if let changeTierContracts = changeTierNavigationVm.changeTierContractsInput {
                if changeTierContracts.contracts.isEmpty {
                    GenericErrorView(
                        title: L10n.somethingWentWrong,
                        description: L10n.General.defaultError,
                        formPosition: .center
                    )
                    .withDismissButton()
                } else {
                    SelectInsuranceScreen(
                        changeTierContractsInput: changeTierContracts,
                        changeTierNavigationVm: changeTierNavigationVm
                    )
                    .routerDestination(for: ChangeTierContract.self) { _ in
                        getScreen
                    }
                }
            } else {
                getScreen
            }
        }
    }

    var getScreen: some View {
        ChangeTierLandingScreen(vm: changeTierNavigationVm.vm)
            .withAlertDismiss()
            .routerDestination(for: ChangeTierRouterActions.self) { [weak changeTierNavigationVm] action in
                if let changeTierNavigationVm {
                    switch action {
                    case .summary:
                        ChangeTierSummaryScreen(
                            changeTierVm: changeTierNavigationVm.vm,
                            changeTierNavigationVm: changeTierNavigationVm
                        )
                        .navigationTitle(L10n.offerUpdateSummaryTitle)
                        .withAlertDismiss()
                    }
                } else {
                    EmptyView()
                }
            }
            .routerDestination(for: ChangeTierRouterActionsWithoutBackButton.self, options: [.hidesBackButton]) {
                [weak changeTierNavigationVm]
                action in
                if let changeTierNavigationVm {
                    switch action {
                    case .commitTier:
                        ChangeTierProcessingView(vm: changeTierNavigationVm.vm)
                    }
                } else {
                    EmptyView()
                }
            }
    }
}

private enum ChangeTierTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .changeTierLandingScreen:
            return .init(describing: ChangeTierLandingScreen.self)
        case .edit:
            return .init(describing: EditScreen.self)
        case .compareTier:
            return .init(describing: CompareTierScreen.self)
        case .info:
            return "Addon Info"
        }
    }

    case changeTierLandingScreen
    case edit(type: EditTierType)
    case compareTier
    case info
}

public struct EditTypeModel: Identifiable, Equatable {
    public let id = UUID().uuidString
    let selectedItem: String?
    let type: EditTierType
}
