import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonInput: Identifiable, Equatable {
    public var id: String = UUID().uuidString

    let contractConfigs: [AddonConfig]?
    let addonSource: AddonSource
    public init(
        addonSource: AddonSource,
        contractConfigs: [AddonConfig]? = nil
    ) {
        self.addonSource = addonSource
        self.contractConfigs = contractConfigs
    }

    public static func == (lhs: ChangeAddonInput, rhs: ChangeAddonInput) -> Bool {
        lhs.id == rhs.id
    }
}

public enum AddonSource: String, Codable {
    case insurances = "INSURANCES"
    case travelCertificates = "TRAVEL_CERTIFICATES"
    case crossSell = "CROSS_SELL"
    case deeplink = "DEEPLINK"
}

struct AddonInfo: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let perilGroups: [PerilGroup]

    struct PerilGroup: Equatable {
        let title: String
        let perils: [Perils]
    }
}

@MainActor
class ChangeAddonNavigationViewModel: ObservableObject {
    @Published var isLearnMorePresented: AddonInfo?
    @Published var isSelectableAddonPresented: AddonOfferSelectable?
    @Published var isAddonProcessingPresented = false
    @Published var changeAddonVm: ChangeAddonViewModel?
    @Published var document: hPDFDocument?
    let input: ChangeAddonInput

    let router = Router()

    init(
        input: ChangeAddonInput
    ) {
        self.input = input
        if input.contractConfigs?.count ?? 0 == 1, let config = input.contractConfigs?.first {
            changeAddonVm = .init(
                config: config,
                addonSource: input.addonSource
            )
        }
    }
}

enum ChangeAddonRouterActions {
    case addonLandingScreen
    case summary
}

public struct ChangeAddonNavigation: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel

    public init(input: ChangeAddonInput) {
        changeAddonNavigationVm = .init(input: input)
    }

    public var body: some View {
        RouterHost(
            router: changeAddonNavigationVm.router,
            options: [.extendedNavigationWidth],
            tracking: ChangeAddonTrackingType.changeAddonScreen
        ) {
            let multipleContracts = changeAddonNavigationVm.input.contractConfigs?.count ?? 0 > 1
            Group {
                if multipleContracts {
                    AddonSelectInsuranceScreen(changeAddonNavigationVm: changeAddonNavigationVm)
                } else {
                    ChangeAddonScreen(vm: changeAddonNavigationVm.changeAddonVm!)
                }
            }
            .withAlertDismiss()
            .routerDestination(for: ChangeAddonRouterActions.self) { action in
                switch action {
                case .summary:
                    ChangeAddonSummaryScreen(changeAddonNavigationVm)
                        .configureTitle(L10n.offerUpdateSummaryTitle)
                        .withAlertDismiss()
                case .addonLandingScreen:
                    ChangeAddonScreen(vm: changeAddonNavigationVm.changeAddonVm!)
                        .withDismissButton()
                }
            }
        }
        .environmentObject(changeAddonNavigationVm)
        .modally(
            presented: $changeAddonNavigationVm.isAddonProcessingPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            AddonProcessingScreen(vm: changeAddonNavigationVm.changeAddonVm!)
                .embededInNavigation(tracking: ChangeAddonTrackingType.processing)
                .environmentObject(changeAddonNavigationVm)
        }
        .modally(
            item: $changeAddonNavigationVm.isLearnMorePresented,
            options: .constant(.alwaysOpenOnTop)
        ) { info in
            AddonLearnMoreView(model: info)
                .withDismissButton()
                .embededInNavigation(
                    options: .extendedNavigationWidth,
                    tracking: ChangeAddonTrackingType.addonLearnMoreView
                )
        }
        .detent(
            item: $changeAddonNavigationVm.isSelectableAddonPresented,
            options: .constant(.alwaysOpenOnTop)
        ) { selectable in
            AddonSelectSubOptionScreen(selectable: selectable, changeAddonNavigationVm: changeAddonNavigationVm)
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: ChangeAddonTrackingType.selectSubOptionScreen
                )
                .environmentObject(changeAddonNavigationVm)
        }
        .detent(
            item: $changeAddonNavigationVm.document,
            transitionType: .detent(style: [.large])
        ) { document in
            PDFPreview(document: document)
        }
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
        case .processing:
            return .init(describing: AddonProcessingScreen.self)
        case .addonLearnMoreView:
            return .init(describing: AddonLearnMoreView.self)
        }
    }

    case changeAddonScreen
    case selectSubOptionScreen
    case processing
    case addonLearnMoreView
}
