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
    @Published var removeAddonVm: RemoveAddonViewModel
    @Published var isProcessingPresented = false
    @Published var document: hPDFDocument?

    init(contractInfo: AddonConfig) {
        self.removeAddonVm = .init(contractInfo: contractInfo)
    }
}

enum RemoveAddonRouterActions {
    case summary
}

public struct RemoveAddonNavigation: View {
    @ObservedObject var removeAddonNavigationVm: RemoveAddonNavigationViewModel

    public init(contractInfo: AddonConfig) {
        removeAddonNavigationVm = .init(contractInfo: contractInfo)
    }

    public var body: some View {
        RouterHost(
            router: removeAddonNavigationVm.router,
            options: [.extendedNavigationWidth],
            tracking: RemoveAddonTrackingType.removeAddonScreen
        ) {
            RemoveAddonScreen(removeAddonVm: removeAddonNavigationVm.removeAddonVm)
                .withAlertDismiss()
                .routerDestination(for: RemoveAddonRouterActions.self) { action in
                    switch action {
                    case .summary:
                        RemoveAddonSummaryScreen(removeAddonNavigationVm: removeAddonNavigationVm)
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
            removeAddonProcessingView
        }
    }

    private var removeAddonProcessingView: some View {
        ProcessingStateView(
            loadingViewText: L10n.tierFlowCommitProcessingLoadingTitle,
            successViewTitle: L10n.addonFlowSuccessTitle,
            successViewBody: L10n.addonFlowSuccessSubtitle(
                removeAddonNavigationVm.removeAddonVm.removeOffer?.activationDate.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                removeAddonNavigationVm.router.dismiss(withDismissingAll: true)
            },
            state: $removeAddonNavigationVm.removeAddonVm.submittingState
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init { removeAddonNavigationVm.isProcessingPresented = false },
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: { removeAddonNavigationVm.router.dismiss(withDismissingAll: true) }
                )
            )
        )
        .onDeinit { [weak removeAddonNavigationVm] in
            if removeAddonNavigationVm?.removeAddonVm.submittingState == .success {
                Task { NotificationCenter.default.post(name: .addonRemoved, object: nil) }
            }
        }
        .embededInNavigation(
            tracking: RemoveAddonTrackingType.processing
        )
    }
}

extension RemoveAddonRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary:
            return .init(describing: RemoveAddonSummaryScreen.self)
        }
    }
}

private enum RemoveAddonTrackingType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .removeAddonScreen:
            return .init(describing: RemoveAddonScreen.self)
        case .processing:
            return "RemoveAddonProcessing"
        }
    }

    case removeAddonScreen
    case processing
}
