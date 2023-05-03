import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceFormScreen: View {
    let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
    var body: some View {
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
                hButton.LargeButtonFilled {

                    UIApplication.dismissKeyboard()
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 6)
            }
        }.presentableStoreLensAnimation(.spring())
            .navigationTitle("Travel certificate")
    }

    @ViewBuilder
    private func datesSection(_ travelInsuranceModel: TravelInsuranceModel) -> some View {
        hSection {
            hRow {
                HStack {
                    hText("Start date")
                }
            }.withCustomAccessory {
                Spacer()
                hText(travelInsuranceModel.startDate.localDateString, style: .body)
                    .foregroundColor(hLabelColor.secondary)
            }.onTap {
                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.send(.navigation(.openDatePicker(type: .startDate)))
            }

            hRow {
                HStack {
                    hText("End date")
                }
            }.withCustomAccessory {
                Spacer()
                Group {
                    if let endDate = travelInsuranceModel.endDate?.localDateString {
                        hText(endDate)
                    } else {
                        Image(uiImage: hCoreUIAssets.calendar.image)
                            .renderingMode(.template)
                    }
                }
                .foregroundColor(hLabelColor.secondary)
            }.onTap {
                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.send(.navigation(.openDatePicker(type: .endDate)))
            }
        }
        .withHeader {
            hText(
                "Traveling dates",
                style: .title2
            )
        }
        .slideUpAppearAnimation()
    }

    @ViewBuilder
    private func insuredMembers(_ travelInsuranceModel: TravelInsuranceModel) -> some View {
        hSection {
            hRow {
                hText("Me", style: .body)
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
                    hText(member.personalNumber, style: .body)
                        .foregroundColor(hLabelColor.secondary)
                }.onTap {
                    store.send(.navigation(.openCoinsured(member: member)))
                }
            }
        }
        .withHeader {
            hText(
                "Insured persons",
                style: .title2
            )
        }
        .slideUpAppearAnimation()
        if travelInsuranceModel.policyCoinsuredPersons.count < store.state.travelInsuranceConfig?.maxNumberOfConisuredPersons ?? 0 {
            Button {
                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.send(.navigation(.openCoinsured(member: nil)))
            } label: {
                hText("Add")
            }
            .slideUpAppearAnimation()
        }

    }
}

struct TravelInsuranceFormScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceFormScreen()
    }
}
