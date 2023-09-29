import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct WhoIsTravelingScreen: View {
    @StateObject var vm = WhoIsTravelingViewModel()

    var body: some View {
        hForm {}
            .hFormTitle(.standard, .title1, L10n.TravelCertificate.whoIsTraveling)
            .hDisableScroll
            .hFormAttachToBottom {
                form
            }
    }

    @ViewBuilder
    var form: some View {
        PresentableStoreLens(
            TravelInsuranceStore.self,
            getter: { state in
                state.travelInsuranceModel
            }
        ) { model in
            VStack(spacing: 16) {
                hSection {
                    hRow {
                        VStack(alignment: .leading) {
                            hText(L10n.TravelCertificate.includedMembersTitle, style: .standardSmall)
                                .foregroundColor(hTextColor.secondary)
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle(isOn: vm.isPolicyHolderIncluded.animation(.default)) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        hText(model?.fullName ?? "", style: .standardLarge)
                                            .foregroundColor(disabledColorOr(hTextColor.primary))
                                        hText(model?.email ?? "")
                                            .foregroundColor(disabledColorOr(hTextColor.secondary))
                                    }
                                }
                                .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
                                if model?.policyCoinsuredPersons.count ?? 0 == 0
                                    && vm.specifications?.numberOfCoInsured ?? 0 > 0
                                {
                                    addPeopleButton
                                }
                            }
                        }
                    }
                    if let coinsuredMembers = model?.policyCoinsuredPersons {
                        ForEach(Array(coinsuredMembers.enumerated()), id: \.element.personalNumber) {
                            index,
                            coinsured in
                            hRow {
                                VStack(alignment: .leading) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack {
                                            hText(coinsured.fullName, style: .standardLarge)
                                            Spacer()
                                            Button {
                                                vm.removeCoinsured(coinsured)
                                            } label: {
                                                Image(uiImage: hCoreUIAssets.close.image).resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                        }
                                        .foregroundColor(hTextColor.primary)
                                        hText(coinsured.personalNumber).foregroundColor(hTextColor.secondary)
                                    }
                                    if (model?.policyCoinsuredPersons.count ?? 0 < vm.specifications?.numberOfCoInsured
                                        ?? 0) && index == coinsuredMembers.count - 1
                                    {
                                        addPeopleButton
                                    }
                                }
                            }
                        }
                    }
                }
                .disableOn(TravelInsuranceStore.self, [.postTravelInsurance])

                hSection {
                    InfoCard(text: L10n.TravelCertificate.whoIsTravelingInfo, type: .info)
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        vm.validateAndSubmit()
                    } content: {
                        hText(L10n.General.submit)
                    }
                }
                .padding(.bottom, 16)
                .trackLoading(TravelInsuranceStore.self, action: .postTravelInsurance)
            }
        }
        .presentableStoreLensAnimation(.default)

    }

    private var addPeopleButton: some View {
        hButton.MediumButton(type: .primaryAlt) {
            vm.addNewCoinsured()
        } content: {
            HStack(spacing: 8) {
                Image(uiImage: hCoreUIAssets.plusSmall.image).resizable().frame(width: 16, height: 16)
                hText(L10n.TravelCertificate.addPeople)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @hColorBuilder
    func disabledColorOr(_ color: some hColor) -> some hColor {
        if vm.isPolicyHolderIncluded.wrappedValue {
            color
        } else {
            hTextColor.disabled
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

    var isPolicyHolderIncluded: Binding<Bool> {
        Binding(
            TravelInsuranceStore.self,
            getter: { state in
                state.travelInsuranceModel?.isPolicyHolderIncluded ?? false
            },
            setter: { code in
                .toogleMyselfAsInsured
            }
        )
    }

    func removeCoinsured(_ coinsured: PolicyCoinsuredPersonModel) {
        store.send(.removePolicyCoInsured(coinsured))
    }

    func addNewCoinsured() {
        store.send(.navigation(.openCoinsured(member: nil)))
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
