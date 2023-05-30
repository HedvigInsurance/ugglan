import Presentation
import SwiftUI
import hCore
import hCoreUI


struct TravelInsuranceFormScreen: View {
    let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
    @State var dateOfOccurrence = Date()
    @State var errorMessage: String?
    var body: some View {
        TravelInsuranceLoadingView(.postTravelInsurance) {
            PresentableStoreLens(
                TravelInsuranceStore.self,
                getter: { state in
                    state.travelInsuranceModel!
                }
            ) { travelInsuranceModel in
                hForm {
                    datesSection(travelInsuranceModel)
                    insuredMembers(travelInsuranceModel)
                }
                .hFormAttachToBottom {
                    VStack {
                        if let errorMessage {
                            HStack {
                                hText(errorMessage, style: .footnote)
                                    .padding(.top, 7)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(hTintColor.red)
                            }
                            .padding([.leading, .trailing], 16)
                        }
                        hButton.LargeButtonFilled {
                            validateAndSubmit()
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        .padding([.leading, .trailing], 16)
                        .padding(.bottom, 6)
                    }
                }
                .navigationTitle(L10n.TravelCertificate.cardTitle)
            }.presentableStoreLensAnimation(.spring())

        }
    }
    
    private func datesSection(_ travelInsuranceModel: TravelInsuranceModel) -> some View {
        let model = store.state.travelInsuranceConfig
        return hSection {
            DatePicker(
                "",
                selection: self.$dateOfOccurrence,
                in: (model?.minStartDate ?? Date())...(model?.maxStartDate ?? Date()),
                displayedComponents: [.date]
            )
            .environment(\.locale, Locale.init(identifier: Localization.Locale.currentLocale.rawValue))
            .datePickerStyle(.graphical)
            .padding([.leading, .trailing], 16)
            .padding([.top], 5)
        }
        .withHeader {
            hText(
                L10n.TravelCertificate.startDateTitle,
                style: .title2
            )
        }.withFooter({
            hText(L10n.TravelCertificate.startDateInfo(store.state.travelInsuranceConfig?.maxDuration ?? 0), style: .footnote)
        })
    }
    
    @ViewBuilder
    private func insuredMembers(_ travelInsuranceModel: TravelInsuranceModel) -> some View {
        hSection {
            hRow {
                hText(L10n.TravelCertificate.me, style: .body)
            }
            .withSelectedAccessory(travelInsuranceModel.isPolicyHolderIncluded)
            .onTap {
                store.send(.toogleMyselfAsInsured)
            }
            ForEach(travelInsuranceModel.policyCoinsuredPersons, id: \.personalNumber) { member in
                hRow {
                    hText(member.fullName, style: .body)
                }.withCustomAccessory {
                    Spacer()
                    HStack(spacing: 8) {
                        hText(member.personalNumber, style: .body)
                            .foregroundColor(hLabelColor.secondary)
                        Button {
                            store.send(.removePolicyCoInsured(member))
                        } label: {
                            Image(uiImage: hCoreUIAssets.close.image)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(.horizontal, 3)
                                .foregroundColor(hLabelColor.primary)
                        }
                        
                    }
                }.onTap {
                    store.send(.navigation(.openCoinsured(member: member)))
                } 
            }
        }
        .withHeader {
            hText(
                L10n.TravelCertificate.includedMembersTitle,
                style: .title2
            )
        }
        if travelInsuranceModel.policyCoinsuredPersons.count < store.state.travelInsuranceConfig?.numberOfCoInsured ?? 0 {
            Button {
                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.send(.navigation(.openCoinsured(member: nil)))
            } label: {
                hText(L10n.TravelCertificate.changeMemberTitle)
            }
        }
    }
    
    func validateAndSubmit() {
        if let (valid, message) = store.state.travelInsuranceModel?.isValidWithMessage() {
            if valid {
                UIApplication.dismissKeyboard()
                store.send(.postTravelInsuranceForm)
            }
            withAnimation {
                errorMessage = message
            }
        }
    }
}

struct TravelInsuranceFormScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceFormScreen()
    }
}
