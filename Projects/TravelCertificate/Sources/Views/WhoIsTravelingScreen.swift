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
                        firstName: contract?.firstName,
                        lastName: contract?.lastName,
                        SSN: contract?.ssn,
                        needsMissingInfo: false
                    )
                    var allValues = [(object: insuranceHolder, displayName: insuranceHolder.fullName ?? "")]
                    let allCoInsuredOnContract =
                        contract?.coInsured.filter({ !$0.hasMissingInfo })
                        .map { (object: $0, displayName: $0.fullName ?? "") } ?? []
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
                    let listOfIncludedTravellers = selectedCoInsured.map {
                        PolicyCoinsuredPersonModel(
                            fullName: ($0.0?.fullName ?? $0.0?.firstName) ?? "",
                            personalNumber: $0.0?.SSN,
                            birthDate: $0.0?.birthDate
                        )
                    }
                    store.send(.setPolicyCoInsured(listOfIncludedTravellers))
                    vm.validateAndSubmit()
                },
                attachToBottom: true,
                infoCard: vm.showInfoCard
                    ? .init(
                        text: L10n.TravelCertificate.missingCoinsuredInfo,
                        buttons: [
                            .init(
                                buttonTitle: L10n.TravelCertificate.missingCoinsuredButton,
                                buttonAction: {
                                    store.send(.dismissTravelInsuranceFlow)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        store.send(.goToEditCoInsured)
                                    }
                                }
                            )
                        ]
                    ) : nil
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

    var showInfoCard: Bool {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        let contractId = store.state.travelInsuranceConfig?.contractId

        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contract = contractStore.state.contractForId(contractId ?? "")

        if contract?.coInsured.allSatisfy({ $0.hasMissingInfo }) ?? false {
            return true
        }
        return false
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
