import ChangeMileageCore
import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
public class ChangeMileageNavigationViewModel {
    let router = NavigationRouter()
    let input: ChangeMileageInput
    var isPickerPresented: MileagePickerModel?
    var isHowFarDoIDriveInfoPresented: InfoViewDataModel?

    /// Set before the landing screen is shown: right away for a single contract, on selection otherwise.
    @ObservationIgnored var vm: ChangeMileageViewModel?

    init(input: ChangeMileageInput) {
        self.input = input
        if input.contracts.count == 1, let contract = input.contracts.first {
            vm = .init(contract: contract)
        }
    }

    func start(with contract: ChangeMileageContract) {
        vm = .init(contract: contract)
        router.push(contract)
    }
}

struct MileagePickerModel: Identifiable, Equatable {
    let id = UUID().uuidString
}

enum ChangeMileageRouterActions: Hashable {
    case summary
}

enum ChangeMileageRouterActionsWithoutBackButton: Hashable {
    case processing
}

extension ChangeMileageRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary: .init(describing: ChangeMileageSummaryScreen.self)
        }
    }
}

extension ChangeMileageRouterActionsWithoutBackButton: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .processing: .init(describing: ChangeMileageProcessingScreen.self)
        }
    }
}

public struct ChangeMileageNavigation: View {
    @State var navigationVm: ChangeMileageNavigationViewModel

    public init(input: ChangeMileageInput) {
        _navigationVm = State(wrappedValue: .init(input: input))
    }

    public var body: some View {
        hNavigationStack(
            router: navigationVm.router,
            options: .extendedNavigationWidth,
            tracking: ChangeMileageTrackingType.landing
        ) {
            root
        }
        .environment(navigationVm)
        .detent(item: $navigationVm.isPickerPresented) { _ in
            if let vm = navigationVm.vm {
                MileagePickerScreen(vm: vm)
                    .embededInNavigation(
                        options: [.navigationType(type: .large), .navigationBarHidden],
                        tracking: ChangeMileageTrackingType.picker
                    )
                    .environment(navigationVm)
            }
        }
        .detent(
            item: $navigationVm.isHowFarDoIDriveInfoPresented,
            presentationStyle: .detent(style: [.height])
        ) { info in
            InfoView(infoViewModel: .init(title: info.title, description: info.description))
        }
    }

    @ViewBuilder
    private var root: some View {
        if navigationVm.input.contracts.isEmpty {
            StateView(
                type: .empty,
                title: L10n.changeMileageEmptyState,
                bodyText: nil,
                formPosition: .center
            )
            .hStateViewButtonConfig(
                .init(
                    dismissButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: { navigationVm.router.dismiss() }
                    )
                )
            )
            .withDismissButton()
        } else if navigationVm.vm != nil, navigationVm.input.contracts.count == 1 {
            landing
        } else {
            SelectMileageInsuranceScreen(navigationVm: navigationVm)
                .routerDestination(for: ChangeMileageContract.self) { _ in
                    landing
                }
        }
    }

    @ViewBuilder
    private var landing: some View {
        if let vm = navigationVm.vm {
            ChangeMileageLandingScreen(vm: vm)
                .withAlertDismiss()
                .routerDestination(for: ChangeMileageRouterActions.self) { action in
                    switch action {
                    case .summary:
                        ChangeMileageSummaryScreen(vm: vm)
                            .navigationTitle(L10n.offerUpdateSummaryTitle)
                    }
                }
                .routerDestination(
                    for: ChangeMileageRouterActionsWithoutBackButton.self,
                    options: [.hidesBackButton]
                ) { action in
                    switch action {
                    case .processing:
                        ChangeMileageProcessingScreen(vm: vm)
                    }
                }
        }
    }
}

private enum ChangeMileageTrackingType: TrackingViewNameProtocol {
    case landing
    case picker

    var nameForTracking: String {
        switch self {
        case .landing: .init(describing: ChangeMileageLandingScreen.self)
        case .picker: .init(describing: MileagePickerScreen.self)
        }
    }
}

extension ChangeMileageContract: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: ChangeMileageLandingScreen.self)
    }
}
