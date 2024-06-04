import EditCoInsuredShared
import Foundation
import SwiftUI

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
                style: .height
            ) { coInsuredModel in
                let contractsSupportingCoInsured = coInsuredModel.contractsSupportingCoInsured
                if contractsSupportingCoInsured.count > 1 {
                    EditCoInsuredSelectInsuranceNavigation(
                        configs: contractsSupportingCoInsured,
                        checkForAlert: {
                            checkForAlert()
                        }
                    )

                } else {
                    getEditCoInsuredNavigation(coInsuredModel: coInsuredModel)
                }
            }
            .fullScreenCover(
                item: $vm.editCoInsuredModelFullScreen
            ) { coInsuredModel in
                getEditCoInsuredNavigation(coInsuredModel: coInsuredModel)
            }
            .detent(
                item: $vm.editCoInsuredModelMissingAlert,
                style: .height
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
                checkForAlert: {
                    checkForAlert()
                }
            )
        }
    }

    func getMissingCoInsuredAlertView(
        missingContractConfig: InsuredPeopleConfig
    ) -> some View {
        EditCoInsuredAlertNavigation(
            config: missingContractConfig,
            checkForAlert: {
                checkForAlert()
            }
        )
    }

    func checkForAlert() {
        vm.editCoInsuredModelDetent = nil
        vm.editCoInsuredModelFullScreen = nil
        vm.editCoInsuredModelMissingAlert = nil

        Task {
            let activeContracts = try await vm.editCoInsuredSharedService.fetchContracts()

            let missingContract = activeContracts.first { contract in
                if contract.upcomingChangedAgreement != nil {
                    return false
                } else {
                    return contract.coInsured
                        .first(where: { coInsured in
                            coInsured.hasMissingInfo && contract.terminationDate == nil
                        }) != nil
                }
            }

            if let missingContract {
                let missingContractConfig = InsuredPeopleConfig(contract: missingContract, fromInfoCard: false)
                vm.editCoInsuredModelMissingAlert = missingContractConfig
            }
        }
    }
}