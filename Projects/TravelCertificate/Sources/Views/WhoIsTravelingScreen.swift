import Contracts
import EditCoInsured
import Foundation
import hCore
import hCoreUI
import PresentableStore
import SwiftUI

struct WhoIsTravelingScreen: View {
    @ObservedObject var vm: WhoIsTravelingViewModel
    @ObservedObject var travelCertificateNavigationVm: TravelCertificateNavigationViewModel
    let itemPickerConfig: ItemConfig<CoInsuredModel>
    init(vm: WhoIsTravelingViewModel, travelCertificateNavigationVm: TravelCertificateNavigationViewModel) {
        self.vm = vm
        self.travelCertificateNavigationVm = travelCertificateNavigationVm
        itemPickerConfig = .init(
            items: vm.coInsuredModelData.compactMap {
                (object: $0, displayName: ItemModel(title: $0.fullName ?? ""))
            },
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
                vm.validateAndSubmit()
            },
            buttonText: L10n.Certificates.createCertificate,
            infoCard: vm.hasMissingCoInsuredData
                ? .init(
                    text: L10n.TravelCertificate.missingCoinsuredInfo,
                    buttons: [
                        .init(
                            buttonTitle: L10n.TravelCertificate.missingCoinsuredButton,
                            buttonAction: {
                                vm.router.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    travelCertificateNavigationVm.editCoInsuredVm.start()
                                }
                            }
                        ),
                    ],
                    placement: .bottom
                ) : nil
        )
    }

    var body: some View {
        ItemPickerScreen<CoInsuredModel>(
            config: itemPickerConfig
        )
        .hFormContentPosition(.bottom)
        .hFormTitle(title: .init(.small, .heading2, L10n.TravelCertificate.whoIsTraveling, alignment: .leading))
        .disabled(vm.isLoading)
    }
}

@MainActor
class WhoIsTravelingViewModel: ObservableObject {
    let specification: TravelInsuranceContractSpecification
    let coInsuredModelData: [CoInsuredModel]
    @Published var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []
    @Published var hasMissingCoInsuredData = false
    var isPolicyHolderIncluded = true
    @Published var isLoading = false
    @Published var error: String?
    let contract: Contracts.Contract?
    let router: Router
    init(specification: TravelInsuranceContractSpecification, router: Router) {
        self.specification = specification
        self.router = router
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contract = contractStore.state.contractForId(specification.contractId)
        let insuranceHolder = CoInsuredModel(
            firstName: contract?.firstName,
            lastName: contract?.lastName,
            SSN: contract?.ssn,
            needsMissingInfo: false
        )
        var coInsured: [CoInsuredModel] = []
        coInsured.append(insuranceHolder)
        coInsured.append(contentsOf: contract?.coInsured.filter { !$0.hasMissingInfo } ?? [])
        coInsuredModelData = coInsured
        hasMissingCoInsuredData = contract?.coInsured.filter(\.hasMissingInfo).count != 0
    }

    func setCoInsured(data: [PolicyCoinsuredPersonModel]) {
        isPolicyHolderIncluded = false
        policyCoinsuredPersons = []
        for coInsured in data {
            if coInsured.fullName == specification.fullName, coInsured.personalNumber == contract?.ssn {
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

    func validateAndSubmit() {
        let (valid, _) = isValidWithMessage()
        if valid {
            UIApplication.dismissKeyboard()
            router.push(TravelCertificateRouterActionsWithoutBackButton.processingScreen)
        }
    }
}

struct WhoIsTravelingView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return WhoIsTravelingScreen(
            vm: .init(
                specification: .init(
                    contractId: "",
                    displayName: "display name",
                    exposureDisplayName: "exposure display name",
                    minStartDate: Date(),
                    maxStartDate: Date(),
                    numberOfCoInsured: 2,
                    maxDuration: 45,
                    email: "email",
                    fullName: "full name"
                ),
                router: .init()
            ),
            travelCertificateNavigationVm: .init()
        )
    }
}
