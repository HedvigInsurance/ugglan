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
    case contractDetail = "CONTRACT_DETAIL"
    case homeScreen = "HOME_SCREEN"
    case homeCrossSellSheet = "HOME_CROSS_SELL_SHEET"
    case travelCertificates = "TRAVEL_CERTIFICATES"
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
@Observable
class ChangeAddonNavigationViewModel {
    var isLearnMorePresented: AddonInfo?
    var isSelectableAddonPresented: AddonOfferSelectable?
    var isAddonProcessingPresented = false
    var changeAddonVm: ChangeAddonViewModel?
    var document: hPDFDocument?
    var activeAddonInfoModel: InfoViewDataModel?
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
    @Bindable var changeAddonNavigationVm: ChangeAddonNavigationViewModel

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
        .environment(changeAddonNavigationVm)
        .modally(
            presented: $changeAddonNavigationVm.isAddonProcessingPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            AddonProcessingScreen(vm: changeAddonNavigationVm.changeAddonVm!)
                .embededInNavigation(tracking: ChangeAddonTrackingType.processing)
                .environment(changeAddonNavigationVm)
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
                .environment(changeAddonNavigationVm)
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
                infoViewModel: .init(
                    title: infoModel.title,
                    description: infoModel.description
                )
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
