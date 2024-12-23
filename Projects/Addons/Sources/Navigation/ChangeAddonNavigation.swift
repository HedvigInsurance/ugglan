import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ChangeAddonInput: Identifiable, Equatable {
    public var id: String = UUID().uuidString

    let contractConfigs: [AddonConfig]?
    let addonId: String?

    public init(
        contractConfigs: [AddonConfig]? = nil,
        addonId: String? = nil
    ) {
        self.contractConfigs = contractConfigs
        self.addonId = addonId
    }

    public static func == (lhs: ChangeAddonInput, rhs: ChangeAddonInput) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum AddonSource: Codable {
    case appUpsellUpgrade
    case appOnlyUpsell

    public var getSource: OctopusGraphQL.UpsellTravelAddonFlow {
        switch self {
        case .appOnlyUpsell: return .appOnlyUpsale
        case .appUpsellUpgrade: return .appUpsellUpgrade
        }
    }
}

@MainActor
class ChangeAddonNavigationViewModel: ObservableObject {
    @Published var isLearnMorePresented: InfoViewDataModel?
    @Published var isChangeCoverageDaysPresented: AddonOffer?
    @Published var isConfirmAddonPresented = false
    @Published var isAddonProcessingPresented = false
    @Published var changeAddonVm: ChangeAddonViewModel?
    @Published var document: hPDFDocument?
    @Published var input: ChangeAddonInput

    let router = Router()

    public init(
        input: ChangeAddonInput
    ) {
        self.input = input
        if input.contractConfigs?.count ?? 0 == 1, let config = input.contractConfigs?.first {
            changeAddonVm = .init(contractId: config.contractId)
        }
    }
}

enum ChangeAddonRouterActions {
    case addonLandingScreen
    case summary
}

public struct ChangeAddonNavigation: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel

    public init(
        input: ChangeAddonInput
    ) {
        self.changeAddonNavigationVm = .init(input: input)
    }

    public var body: some View {
        RouterHost(
            router: changeAddonNavigationVm.router,
            options: [],
            tracking: ChangeAddonTrackingType.changeAddonScreen
        ) {
            Group {
                if changeAddonNavigationVm.input.contractConfigs?.count ?? 0 > 1 {
                    selectInsuranceScreen
                } else {
                    ChangeAddonScreen(changeAddonVm: changeAddonNavigationVm.changeAddonVm!)
                        .withAlertDismiss()
                }
            }
            .routerDestination(for: ChangeAddonRouterActions.self) { action in
                switch action {
                case .summary:
                    ChangeAddonSummaryScreen(
                        changeAddonNavigationVm: changeAddonNavigationVm
                    )
                    .configureTitle(L10n.offerUpdateSummaryTitle)
                    .withAlertDismiss()
                case .addonLandingScreen:
                    ChangeAddonScreen(changeAddonVm: changeAddonNavigationVm.changeAddonVm!)
                        .withAlertDismiss()
                }
            }
        }
        .environmentObject(changeAddonNavigationVm)
        .modally(
            presented: $changeAddonNavigationVm.isAddonProcessingPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            AddonProcessingScreen(vm: changeAddonNavigationVm.changeAddonVm!)
                .embededInNavigation(
                    tracking: ChangeAddonTrackingType.processing
                )
                .environmentObject(changeAddonNavigationVm)
        }
        .detent(
            item: $changeAddonNavigationVm.isLearnMorePresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { infoViewModel in
            InfoView(
                title: infoViewModel.title ?? "",
                description: infoViewModel.description ?? ""
            )
        }
        .detent(
            item: $changeAddonNavigationVm.isChangeCoverageDaysPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { addOn in
            AddonSelectSubOptionScreen(addonOffer: addOn, changeAddonNavigationVm: changeAddonNavigationVm)
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: ChangeAddonTrackingType.selectSubOptionScreen
                )
                .environmentObject(changeAddonNavigationVm)
        }
        .detent(
            presented: $changeAddonNavigationVm.isConfirmAddonPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop),
            content: {
                ConfirmChangeAddonScreen()
                    .embededInNavigation(
                        tracking: ChangeAddonTrackingType.confirmAddonScreen
                    )
                    .environmentObject(changeAddonNavigationVm)
            }
        )
        .detent(
            item: $changeAddonNavigationVm.document,
            style: [.large]
        ) { document in
            PDFPreview(document: document)
        }
    }

    private var selectInsuranceScreen: some View {
        AddonSelectInsuranceScreen(
            changeAddonVm: changeAddonNavigationVm.changeAddonVm
                ?? .init(
                    contractId: changeAddonNavigationVm.input.contractConfigs?.first?.contractId ?? ""
                )
        )
        .withDismissButton()
    }
}

extension ChangeAddonRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary:
            return .init(describing: ChangeAddonSummaryScreen.self)
        case .addonLandingScreen:
            return .init(describing: ChangeAddonScreen.self)
        }
    }
}

private enum ChangeAddonTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .changeAddonScreen:
            return .init(describing: ChangeAddonScreen.self)
        case .selectSubOptionScreen:
            return .init(describing: AddonSelectSubOptionScreen.self)
        case .confirmAddonScreen:
            return .init(describing: ConfirmChangeAddonScreen.self)
        case .processing:
            return .init(describing: AddonProcessingScreen.self)
        }
    }

    case changeAddonScreen
    case selectSubOptionScreen
    case confirmAddonScreen
    case processing
}