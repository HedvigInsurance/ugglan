import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
class RemoveAddonNavigationViewModel {
    let router = NavigationRouter()
    let removeAddonVm: RemoveAddonViewModel
    var isProcessingPresented = false
    var document: hPDFDocument?
    let goDirectlyToSummary: Bool

    init(_ removeOffer: AddonRemoveOfferWithSelectedItems) {
        self.removeAddonVm = .init(removeOffer)
        goDirectlyToSummary = removeOffer.cost != nil
    }
}

enum RemoveAddonRouterActions {
    case summary
}
public struct RemoveAddonNavigation: View {
    @State var removeAddonNavigationVm: RemoveAddonNavigationViewModel
    let removeAddonVm: RemoveAddonViewModel

    public init(_ removeOffer: AddonRemoveOfferWithSelectedItems) {
        let vm = RemoveAddonNavigationViewModel(removeOffer)
        self._removeAddonNavigationVm = .init(wrappedValue: vm)
        self.removeAddonVm = vm.removeAddonVm
    }

    public var body: some View {
        hNavigationStack(
            router: removeAddonNavigationVm.router,
            options: [.extendedNavigationWidth],
            tracking: RemoveAddonTrackingType.removeAddonScreen
        ) {
            if !removeAddonNavigationVm.goDirectlyToSummary {
                RemoveAddonScreen(removeAddonNavigationVm.removeAddonVm)
                    .withAlertDismiss()
                    .routerDestination(for: RemoveAddonRouterActions.self) { action in
                        switch action {
                        case .summary:
                            RemoveAddonSummaryScreen(removeAddonNavigationVm)
                                .navigationTitle(L10n.offerUpdateSummaryTitle)
                        }
                    }
            } else {
                RemoveAddonSummaryScreen(removeAddonNavigationVm)
                    .navigationTitle(L10n.offerUpdateSummaryTitle)
            }
        }
        .environment(removeAddonNavigationVm)
        .modally(
            presented: $removeAddonNavigationVm.isProcessingPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            RemoveAddonProcessingScreen(vm: removeAddonVm)
                .embededInNavigation(tracking: RemoveAddonTrackingType.processing)
                .environment(removeAddonNavigationVm)
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
