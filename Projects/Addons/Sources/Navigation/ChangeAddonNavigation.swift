import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonInput {
    let contractId: String

    public init(
        contractId: String
    ) {
        self.contractId = contractId
    }
}

@MainActor
class ChangeAddonNavigationViewModel: ObservableObject {
    @Published var isLearnMorePresented: InfoViewDataModel?
    @Published var isChangeCoverageDaysPresented: AddonOptionModel?
    @Published var changeAddonVm: ChangeAddonViewModel
    let router = Router()

    public init(
        input: ChangeAddonInput
    ) {
        changeAddonVm = ChangeAddonViewModel(contractId: input.contractId)
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
            AddonSelectSubOptionScreen(addonOption: addOn, changeAddonNavigationVm: changeAddonNavigationVm)
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
            return .init(describing: ChangeAddonRouterActions.self)
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
