import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct RemoveAddonInput: Identifiable, Equatable {
    public var id: String { contractInfo.contractId }
    public let contractInfo: AddonConfig

    public init(contractInfo: AddonConfig) {
        self.contractInfo = contractInfo
    }
}

@MainActor
class RemoveAddonNavigationViewModel: ObservableObject {
    let router = Router()
    let removeAddonVm: RemoveAddonViewModel
    @Published var isProcessingPresented = false
    @Published var document: hPDFDocument?

    public init(_ contractInfo: AddonConfig) {
        self.removeAddonVm = .init(contractInfo)
    }
}

enum RemoveAddonRouterActions {
    case summary
}
public struct RemoveAddonNavigation: View {
    @StateObject var removeAddonNavigationVm: RemoveAddonNavigationViewModel
    @ObservedObject var removeAddonVm: RemoveAddonViewModel

    public init(_ config: AddonConfig) {
        let vm = RemoveAddonNavigationViewModel(config)
        self._removeAddonNavigationVm = .init(wrappedValue: vm)
        self.removeAddonVm = vm.removeAddonVm
    }

    public var body: some View {
        RouterHost(
            router: removeAddonNavigationVm.router,
            options: [.extendedNavigationWidth],
            tracking: RemoveAddonTrackingType.removeAddonScreen
        ) {
            RemoveAddonScreen(removeAddonNavigationVm.removeAddonVm)
                .withAlertDismiss()
                .routerDestination(for: RemoveAddonRouterActions.self) { action in
                    switch action {
                    case .summary:
                        RemoveAddonSummaryScreen(removeAddonNavigationVm)
                            .configureTitle(L10n.offerUpdateSummaryTitle)
                            .withAlertDismiss()
                    }
                }
        }
        .environmentObject(removeAddonNavigationVm)
        .modally(
            presented: $removeAddonNavigationVm.isProcessingPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            RemoveAddonProcessingView(vm: removeAddonVm)
                .embededInNavigation(tracking: RemoveAddonTrackingType.processing)
                .environmentObject(removeAddonNavigationVm)
        }
    }
}

extension RemoveAddonRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary: return .init(describing: RemoveAddonSummaryScreen.self)
        }
    }
}

private enum RemoveAddonTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .removeAddonScreen: return .init(describing: RemoveAddonScreen.self)
        case .processing: return "RemoveAddonProcessing"
        }
    }

    case removeAddonScreen
    case processing
}
