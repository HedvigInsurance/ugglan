import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ChangeAddonInput: Identifiable, Equatable {
    public var id: String {
        contractId ?? addonId ?? ""
    }

    let contractId: String?
    let addonId: String?

    public init(
        contractId: String? = nil,
        addonId: String? = nil
    ) {
        self.contractId = contractId
        self.addonId = addonId
    }

    public static func == (lhs: ChangeAddonInput, rhs: ChangeAddonInput) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class ChangeAddonNavigationViewModel: ObservableObject {
    @Published var isLearnMorePresented: InfoViewDataModel?
    @Published var isChangeCoverageDaysPresented: AddonOffer?
    @Published var isConfirmAddonPresented = false
    @Published var isAddonProcessingPresented = false
    @Published var changeAddonVm: ChangeAddonViewModel
    @Published var document: hPDFDocument?

    let router = Router()

    public init(
        input: ChangeAddonInput
    ) {
        changeAddonVm = ChangeAddonViewModel(contractId: input.contractId ?? "")
    }
}

enum ChangeAddonRouterActions {
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
            ChangeAddonScreen(changeAddonVm: changeAddonNavigationVm.changeAddonVm)
                .withAlertDismiss()
                .routerDestination(for: ChangeAddonRouterActions.self) { action in
                    switch action {
                    case .summary:
                        ChangeAddonSummaryScreen(
                            changeAddonNavigationVm: changeAddonNavigationVm
                        )
                        .configureTitle(L10n.offerUpdateSummaryTitle)
                        .withAlertDismiss()
                    }
                }
        }
        .environmentObject(changeAddonNavigationVm)
        .modally(
            presented: $changeAddonNavigationVm.isAddonProcessingPresented
        ) {
            AddonProcessingScreen(vm: changeAddonNavigationVm.changeAddonVm)
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
}

extension ChangeAddonRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary:
            return .init(describing: ChangeAddonSummaryScreen.self)
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
        }
    }

    case changeAddonScreen
    case selectSubOptionScreen
    case confirmAddonScreen
}
