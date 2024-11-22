import Foundation
import SwiftUI
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

public class ChangeAddonNavigationViewModel: ObservableObject {
    @Published public var isLearnMorePresented = false
    @Published public var isChangeCoverageDaysPresented: AddonModel?

    @Published var changeAddonVm: ChangeAddonViewModel?

    let input: ChangeAddonInput
    let router = Router()

    public init(
        input: ChangeAddonInput
    ) {
        self.input = input
    }
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
            ChangeAddonScreen(changeAddonVm: changeAddonNavigationVm.changeAddonVm ?? .init())
                .withDismissButton()
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
            style: [.height, .large],
            options: .constant(.alwaysOpenOnTop)
        ) { addOn in
            ChangeCoverageDaysScreen(addon: addOn)
        }
    }
}

private enum ChangeAddonTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .changeAddonScreen:
            return .init(describing: ChangeAddonScreen.self)
        }
    }

    case changeAddonScreen
}
