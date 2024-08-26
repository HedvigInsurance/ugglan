import Contracts
import EditCoInsuredShared
import Foundation
import StoreContainer
import SwiftUI
import hCore
import hCoreUI

struct WhoIsTravelingScreen: View {
    @ObservedObject var vm: WhoIsTravelingViewModel
    @EnvironmentObject var router: Router
    @EnvironmentObject var travelCertificateNavigationVm: TravelCertificateNavigationViewModel

    var body: some View {
        ItemPickerScreen<CoInsuredModel>(
            config: .init(
                items: {
                    return vm.coInsuredModelData.compactMap({
                        (object: $0, displayName: ItemModel(title: $0.fullName ?? ""))
                    })
                }(),
                preSelectedItems: {
                    if let first = vm.coInsuredModelData.first {
                        return [first]
                    }
                    return []
                },
                onSelected: { selectedCoInsured in
                    let listOfIncludedTravellers = selectedCoInsured.map {
                        PolicyCoinsuredPersonModel(
                            fullName: ($0.0?.fullName ?? $0.0?.firstName) ?? "",
                            personalNumber: $0.0?.SSN,
                            birthDate: $0.0?.birthDate
                        )
                    }
                    vm.setCoInsured(data: listOfIncludedTravellers)
                    validateAndSubmit()
                },
                attachToBottom: true,
                hButtonText: L10n.General.submit,
                infoCard: vm.hasMissingCoInsuredData
                    ? .init(
                        text: L10n.TravelCertificate.missingCoinsuredInfo,
                        buttons: [
                            .init(
                                buttonTitle: L10n.TravelCertificate.missingCoinsuredButton,
                                buttonAction: {
                                    router.dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        travelCertificateNavigationVm.editCoInsuredVm.start()
                                    }
                                }
                            )
                        ],
                        placement: .bottom
                    ) : nil
            )
        )
        .padding(.bottom, .padding16)
        .hFormTitle(title: .init(.standard, .displayXSLong, L10n.TravelCertificate.whoIsTraveling))
        .hDisableScroll
        .disabled(vm.isLoading)
    }

    func validateAndSubmit() {
        let (valid, _) = vm.isValidWithMessage()
        if valid {
            UIApplication.dismissKeyboard()
            router.push(TravelCertificateRouterActionsWithoutBackButton.processingScreen)
        }
    }
}

class WhoIsTravelingViewModel: ObservableObject {
    let specification: TravelInsuranceContractSpecification
    let coInsuredModelData: [CoInsuredModel]
    @Published var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []
    @Published var hasMissingCoInsuredData = false
    var isPolicyHolderIncluded = true
    @Published var isLoading = false
    @Published var error: String?
    let contract: Contracts.Contract?
    init(specification: TravelInsuranceContractSpecification) {
        self.specification = specification

        let contractStore: ContractStore = hGlobalPresentableStoreContainer.get()
        contract = contractStore.state.contractForId(specification.contractId)
        let insuranceHolder = CoInsuredModel(
            firstName: contract?.firstName,
            lastName: contract?.lastName,
            SSN: contract?.ssn,
            needsMissingInfo: false
        )
        var coInsured: [CoInsuredModel] = []
        coInsured.append(insuranceHolder)
        coInsured.append(contentsOf: contract?.coInsured.filter({ !$0.hasMissingInfo }) ?? [])
        coInsuredModelData = coInsured
        hasMissingCoInsuredData = contract?.coInsured.allSatisfy({ $0.hasMissingInfo }) ?? false
    }

    func setCoInsured(data: [PolicyCoinsuredPersonModel]) {
        isPolicyHolderIncluded = false
        policyCoinsuredPersons = []
        data.forEach { coInsured in
            if coInsured.fullName == specification.fullName && coInsured.personalNumber == contract?.ssn {
                isPolicyHolderIncluded = true
            } else {
                policyCoinsuredPersons.append(contentsOf: data)
            }
        }
    }

    func isValidWithMessage() -> (valid: Bool, message: String?) {
        let isValid = isPolicyHolderIncluded || policyCoinsuredPersons.count > 0
        var message: String? = nil
        if !isValid {
            message = L10n.TravelCertificate.coinsuredErrorLabel
        }
        return (isValid, message)
    }
}

struct WhoIsTravelingView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return WhoIsTravelingScreen(
            vm:
                .init(
                    specification: .init(
                        contractId: "",
                        minStartDate: Date(),
                        maxStartDate: Date(),
                        numberOfCoInsured: 2,
                        maxDuration: 45,
                        street: "Street",
                        email: "email",
                        fullName: "full name"
                    )
                )
        )
    }
}
