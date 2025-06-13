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
        return lhs.id == rhs.id
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
    let perils: [Perils]
}

@MainActor
class ChangeAddonNavigationViewModel: ObservableObject {
    @Published var isLearnMorePresented: AddonInfo?
    @Published var isChangeCoverageDaysPresented: AddonOffer?
    @Published var isConfirmAddonPresented = false
    @Published var isAddonProcessingPresented = false
    @Published var changeAddonVm: ChangeAddonViewModel?
    @Published var document: hPDFDocument?
    let input: ChangeAddonInput

    let router = Router()

    public init(
        input: ChangeAddonInput
    ) {
        self.input = input
        if input.contractConfigs?.count ?? 0 == 1, let config = input.contractConfigs?.first {
            changeAddonVm = .init(
                contractId: config.contractId,
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
        .modally(
            item: $changeAddonNavigationVm.isLearnMorePresented,
            options: .constant(.alwaysOpenOnTop)
        ) { info in
            AddonLearnMoreView(model: info)
                .withDismissButton()
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: ChangeAddonTrackingType.addonLearnMoreView
                )
        }
        .detent(
            item: $changeAddonNavigationVm.isChangeCoverageDaysPresented,
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

            options: .constant(.alwaysOpenOnTop),
            content: {
                ConfirmChangeAddonScreen()
                    .embededInNavigation(
                        options: .navigationBarHidden,
                        tracking: ChangeAddonTrackingType.confirmAddonScreen
                    )
                    .environmentObject(changeAddonNavigationVm)
            }
        )
        .detent(
            item: $changeAddonNavigationVm.document,
            transitionType: .detent(style: [.large])
        ) { document in
            PDFPreview(document: document)
        }
    }

    private var selectInsuranceScreen: some View {
        AddonSelectInsuranceScreen(changeAddonNavigationVm: changeAddonNavigationVm)
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
        case .addonLearnMoreView:
            return .init(describing: AddonLearnMoreView.self)
        }
    }

    case changeAddonScreen
    case selectSubOptionScreen
    case confirmAddonScreen
    case processing
    case addonLearnMoreView
}
