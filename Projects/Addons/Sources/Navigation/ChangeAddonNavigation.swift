import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonInput {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    let contractId: String

    public init(
        contractId: String
    ) {
        self.contractId = contractId
    }
}

@MainActor
public class ChangeAddonNavigationViewModel: ObservableObject {
    @Published public var isLearnMorePresented = false
    @Published public var isChangeCoverageDaysPresented: AddonOptionModel?
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
    let input: ChangeAddonInput

    public init(
        input: ChangeAddonInput
    ) {
        self.input = input
        self.changeAddonNavigationVm = .init(input: input)
    }

    public var body: some View {
        RouterHost(
            router: changeAddonNavigationVm.router,
            options: [],
            tracking: ChangeAddonTrackingType.changeAddonScreen
        ) {
            ChangeAddonScreen(changeAddonVm: changeAddonNavigationVm.changeAddonVm)
                .withDismissButton()
                .routerDestination(for: ChangeAddonRouterActions.self) { action in
                    switch action {
                    case .summary:
                        ChangeAddonSummaryScreen(
                            changeAddonNavigationVm: changeAddonNavigationVm
                        )
                        .configureTitle(L10n.offerUpdateSummaryTitle)
                        .withDismissButton()
                    }
                }
        }
        .environmentObject(changeAddonNavigationVm)
        .detent(
            presented: $changeAddonNavigationVm.isLearnMorePresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) {
            InfoView(
                title: "What is Reseskydd Plus?",
                description:
                    "Med reseskyddet som ingår i din hemförsäkring får du hjälp vid olycksfall och akut sjukdom eller tandbesvär som kräver sjukvård under din resa.\n\nSkyddet gäller också om ni tvingas evakuera resmålet på grund av det utbryter krig, naturkatastrof eller epidemi. Du kan även få ersättning om du måste avbryta resan på grund av att något allvarligt har hänt med en närstående hemma."
            )
        }
        .detent(
            item: $changeAddonNavigationVm.isChangeCoverageDaysPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { addOn in
            ChangeCoverageDaysScreen(addonOption: addOn, changeAddonNavigationVm: changeAddonNavigationVm)
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: ChangeAddonTrackingType.changeCoverageDaysScreen
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
        case .changeCoverageDaysScreen:
            return .init(describing: ChangeCoverageDaysScreen.self)
        }
    }

    case changeAddonScreen
    case changeCoverageDaysScreen
}
