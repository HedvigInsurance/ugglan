import Contracts
import EditCoInsured
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct WhoIsTravelingScreen: View {
    @StateObject var vm = WhoIsTravelingViewModel()
    @PresentableStore var store: TravelInsuranceStore

    var body: some View {
        PresentableStoreLens(
            TravelInsuranceStore.self,
            getter: { state in
                state
            }
        ) { state in
            let travelInsuranceConfig = state.travelInsuranceConfig
            CheckboxPickerScreen<CoInsuredModel>(
                items: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let contract = contractStore.state.contractForId(travelInsuranceConfig?.contractId ?? "")

                    let insuranceHolder = CoInsuredModel(
                        firstName: state.travelInsuranceModel?.fullName,
                        SSN: contract?.ssn,
                        needsMissingInfo: false
                    )
                    var allValues = [(object: insuranceHolder, displayName: insuranceHolder.firstName ?? "")]
                    let allCoInsuredOnContract =
                        contract?.coInsured.map { (object: $0, displayName: $0.fullName ?? "") } ?? []
                    allValues.append(contentsOf: allCoInsuredOnContract)
                    return allValues
                }(),
                preSelectedItems: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let insuranceHolder = CoInsuredModel(
                        firstName: state.travelInsuranceModel?.fullName,
                        SSN: contractStore.state.contractForId(travelInsuranceConfig?.contractId ?? "")?.ssn,
                        needsMissingInfo: false
                    )
                    return [insuranceHolder]
                },
                onSelected: { selectedCoInsured in
                    let store: TravelInsuranceStore = globalPresentableStoreContainer.get()

                    selectedCoInsured.forEach { coInsured in
                        let contractStore: ContractStore = globalPresentableStoreContainer.get()
                        let contract = contractStore.state.contractForId(travelInsuranceConfig?.contractId ?? "")

                        let newPolicyCoInsured = PolicyCoinsuredPersonModel(
                            fullName: (coInsured.0?.fullName ?? coInsured.0?.firstName) ?? "",
                            personalNumber: coInsured.0?.SSN ?? coInsured.0?.birthDate ?? ""
                        )
                        store.send(.setPolicyCoInsured(newPolicyCoInsured))

                        if newPolicyCoInsured.fullName == contract?.fullName
                            && newPolicyCoInsured.personalNumber == contract?.ssn
                        {
                            store.send(.toogleMyselfAsInsured)
                        }
                    }
                    vm.validateAndSubmit()
                },
                attachToBottom: true,
                infoCard: .init(
                    text: "If you want to add a co-insured to the certificate you need to register them first",
                    buttons: [
                        .init(
                            buttonTitle: "Register now",
                            buttonAction: {
                                let url = "https://hedvigtest.page.link/travelCertificate"
                                if let url = URL(string: url) {
                                    store.send(.goToDeepLink(url: url))
                                }
                            }
                        )
                    ]
                )
            )
            .padding(.bottom, 16)
            .hFormTitle(.standard, .title1, L10n.TravelCertificate.whoIsTraveling)
            .hDisableScroll
            .disableOn(TravelInsuranceStore.self, [.postTravelInsurance])
        }
    }
}

class WhoIsTravelingViewModel: ObservableObject {
    let specifications: TravelInsuranceContractSpecification?
    @PresentableStore var store: TravelInsuranceStore
    init() {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        self.specifications = store.state.travelInsuranceConfig
    }

    func validateAndSubmit() {
        if let (valid, _) = store.state.travelInsuranceModel?.isValidWithMessage() {
            if valid {
                UIApplication.dismissKeyboard()
                store.send(.postTravelInsuranceForm)
                store.send(.navigation(.openProcessingScreen))
            }
        }
    }
}

struct WhoIsTravelingView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return WhoIsTravelingScreen()
    }
}
