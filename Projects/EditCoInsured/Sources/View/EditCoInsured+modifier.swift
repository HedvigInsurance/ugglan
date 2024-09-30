import EditCoInsuredShared
import Foundation
import SwiftUI
import hCoreUI

extension View {
    public func handleEditCoInsured(with vm: EditCoInsuredViewModel) -> some View {
        return modifier(EditCoInsured(vm: vm))
    }
}

struct EditCoInsured: ViewModifier {
    @ObservedObject var vm: EditCoInsuredViewModel

    func body(content: Content) -> some View {
        content
            .detent(
                item: $vm.editCoInsuredModelDetent,
                style: [.height]
            ) { coInsuredModel in
                let contractsSupportingCoInsured = coInsuredModel.contractsSupportingCoInsured
                if contractsSupportingCoInsured.count > 1 {
                    EditCoInsuredSelectInsuranceNavigation(
                        configs: contractsSupportingCoInsured
                    )
                    .environmentObject(vm)

                } else {
                    getEditCoInsuredNavigation(coInsuredModel: coInsuredModel)
                }
            }
            .modally(
                item: $vm.editCoInsuredModelFullScreen
            ) { coInsuredModel in
                getEditCoInsuredNavigation(coInsuredModel: coInsuredModel)
            }
            .detent(
                item: $vm.editCoInsuredModelMissingAlert,
                style: [.height]
            ) { config in
                getMissingCoInsuredAlertView(
                    missingContractConfig: config
                )
            }
    }

    @ViewBuilder
    func getEditCoInsuredNavigation(coInsuredModel: EditCoInsuredNavigationModel) -> some View {
        if let contract = coInsuredModel.contractsSupportingCoInsured.first {
            EditCoInsuredNavigation(
                config: contract,
                openSpecificScreen: coInsuredModel.openSpecificScreen
            )
            .environmentObject(vm)
        }
    }

    func getMissingCoInsuredAlertView(
        missingContractConfig: InsuredPeopleConfig
    ) -> some View {
        EditCoInsuredAlertNavigation(
            config: missingContractConfig
        )
        .environmentObject(vm)
    }
}

enum InsuredPeopleConfigType {
    case oneItem
    case list
}

extension InsuredPeopleConfigType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .oneItem:
            return .init(describing: InsuredPeopleNewScreen.self)
        case .list:
            return .init(describing: ItemPickerScreen<InsuredPeopleConfig>.self)
        }
    }
}
