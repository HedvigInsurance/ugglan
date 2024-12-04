import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonInput: Identifiable, Equatable {
    public var id: String {
        contractId ?? ""
    }

    let contractId: String?

    public init(
        contractId: String?
    ) {
        self.contractId = contractId
    }

    public static func == (lhs: ChangeAddonInput, rhs: ChangeAddonInput) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class ChangeAddonNavigationViewModel: ObservableObject {
    @Published var isLearnMorePresented: InfoViewDataModel?
    @Published var isChangeCoverageDaysPresented: AddonOffer?
    @Published var changeAddonVm: ChangeAddonViewModel
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

enum ChangeAddonRouterActionsWithoutBackButton {
    case commitAddon
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
                .routerDestination(for: ChangeAddonRouterActionsWithoutBackButton.self, options: [.hidesBackButton]) {
                    action in
                    switch action {
                    case .commitAddon:
                        AddonProcessingScreen(vm: changeAddonNavigationVm.changeAddonVm)
                    }
                }
        }
        .environmentObject(changeAddonNavigationVm)
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

extension ChangeAddonRouterActionsWithoutBackButton: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .commitAddon:
            return .init(describing: AddonProcessingScreen.self)
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
        }
    }

    case changeAddonScreen
    case selectSubOptionScreen
}
