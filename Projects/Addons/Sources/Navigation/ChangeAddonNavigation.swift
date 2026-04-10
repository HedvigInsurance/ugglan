import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonInput: Identifiable, Equatable, Sendable {
    public let id: String = UUID().uuidString

    public let contractInfos: [AddonContractInfo]?
    let addonSource: AddonSource
    public let preselectedAddonTitle: String?
    public init(
        addonSource: AddonSource,
        contractInfos: [AddonContractInfo]? = nil,
        preselectedAddonTitle: String? = nil
    ) {
        self.addonSource = addonSource
        self.contractInfos = contractInfos
        self.preselectedAddonTitle = preselectedAddonTitle
    }
}

public enum AddonSource: String, Codable, Sendable {
    case insurances = "INSURANCES_TAB"
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
    @Published var activeAddonInfoModel: InfoViewDataModel?
    public let input: ChangeAddonInput

    let router = NavigationRouter()

    init(input: ChangeAddonInput) {
        self.input = input
    }

    init(offer: AddonOffer, preselectedAddonTitle: String? = nil) {
        self.input = .init(addonSource: offer.source)
        changeAddonVm = .init(offer: offer, preselectedAddonTitle: preselectedAddonTitle)
    }
}

enum ChangeAddonRouterActions {
    case addonLandingScreen
    case summary
}

struct ChangeAddonNavigation: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel

    init(input: ChangeAddonInput) {
        changeAddonNavigationVm = .init(input: input)
    }
    init(offer: AddonOffer, preselectedAddonTitle: String? = nil) {
        changeAddonNavigationVm = .init(offer: offer, preselectedAddonTitle: preselectedAddonTitle)
    }

    var body: some View {
        hNavigationStack(
            router: changeAddonNavigationVm.router,
            options: [.extendedNavigationWidth],
            tracking: ChangeAddonTrackingType.changeAddonScreen
        ) {
            let multipleContracts = changeAddonNavigationVm.input.contractInfos?.count ?? 0 > 1
            Group {
                if multipleContracts {
                    AddonSelectInsuranceScreen(.init(changeAddonNavigationVm))
                } else {
                    ChangeAddonScreen(vm: changeAddonNavigationVm.changeAddonVm!)
                        .withAlertDismiss()
                }
            }
            .routerDestination(for: ChangeAddonRouterActions.self) { action in
                switch action {
                case .summary:
                    ChangeAddonSummaryScreen(changeAddonNavigationVm)
                        .navigationTitle(L10n.offerUpdateSummaryTitle)
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
            presentationStyle: .detent(style: [.large])
        ) { document in
            PDFPreview(document: document)
        }
        .detent(
            item: $changeAddonNavigationVm.activeAddonInfoModel,
            options: .constant(.withoutGrabber)
        ) { infoModel in
            InfoView(
                title: infoModel.title,
                description: infoModel.description
            )
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
