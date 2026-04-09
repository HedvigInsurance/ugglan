import Foundation
import SwiftUI
import hCoreUI

extension View {
    public func handleEditStakeholders(
        with vm: EditStakeholdersViewModel
    ) -> some View {
        modifier(EditStakeholders(vm: vm))
    }
}

struct EditStakeholders: ViewModifier {
    @ObservedObject var vm: EditStakeholdersViewModel
    @State var errorRouter = NavigationRouter()
    func body(content: Content) -> some View {
        content
            .detent(
                item: $vm.editStakeholderModelDetent,
                presentationStyle: .detent(style: [.height])
            ) { stakeholderModel in
                let contractsSupportingStakeholders = stakeholderModel.contractsSupportingStakeholders
                if contractsSupportingStakeholders.count > 1, let stakeholderType = vm.stakeholderType {
                    EditStakeholdersSelectInsuranceNavigation(
                        configs: contractsSupportingStakeholders,
                        stakeholderType: stakeholderType,
                    )
                    .environmentObject(vm)
                } else {
                    getEditStakeholdersNavigation(stakeholderModel: stakeholderModel)
                }
            }
            .modally(
                item: $vm.editStakeholderModelFullScreen
            ) { stakeholderModel in
                getEditStakeholdersNavigation(stakeholderModel: stakeholderModel)
            }
            .detent(
                item: $vm.editStakeholderModelMissingAlert,
                presentationStyle: .detent(style: [.height])
            ) { config in
                getMissingStakeholderAlertView(
                    missingContractConfig: config
                )
            }
            .detent(
                item: $vm.editStakeholderModelError,

                options: .constant([.alwaysOpenOnTop])
            ) { errorModel in
                GenericErrorView(description: errorModel.errorMessage, formPosition: .compact)
                    .hStateViewButtonConfig(
                        .init(
                            actionButtonAttachedToBottom: .init(
                                buttonAction: {
                                    errorRouter.dismiss()
                                }
                            )
                        )
                    )
                    .embededInNavigation(
                        router: errorRouter,
                        tracking: StakeholderConfigType.error(vm.stakeholderType!)
                    )
            }
    }

    @ViewBuilder
    func getEditStakeholdersNavigation(stakeholderModel: EditStakeholdersNavigationModel) -> some View {
        if let contract = stakeholderModel.contractsSupportingStakeholders.first {
            EditStakeholdersNavigation(
                config: contract,
                openSpecificScreen: stakeholderModel.openSpecificScreen
            )
            .environmentObject(vm)
        }
    }

    func getMissingStakeholderAlertView(
        missingContractConfig: StakeholdersConfig
    ) -> some View {
        EditStakeholdersAlertNavigation(
            config: missingContractConfig
        )
        .environmentObject(vm)
    }
}

enum StakeholderConfigType {
    case oneItem(StakeholderType)
    case list(StakeholderType)
    case error(StakeholderType)
}

extension StakeholderConfigType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .oneItem(let type): type.trackingName(for: "ListScreen")
        case .list(let type): type.trackingName(for: "SelectInsuranceScreen")
        case .error(let type): type.trackingName(for: "GenericError")
        }
    }
}
