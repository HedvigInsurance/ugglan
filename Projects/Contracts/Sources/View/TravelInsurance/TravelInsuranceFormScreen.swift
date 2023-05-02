import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceFormScreen: View {
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
        }
    }

    @ViewBuilder
    private func datesSection(_ travelInsuranceModel: TravelInsuranceModel) -> some View {
        hSection {
            hRow {
                HStack {
                    hText("Start date", style: .body)
                    Spacer()
                    hText(travelInsuranceModel.startDate, style: .body)
                        .foregroundColor(hLabelColor.link)
                }
            }

            hRow {
                HStack {
                    hText("End date", style: .body)
                    Spacer()
                    hText(travelInsuranceModel.endDate ?? "", style: .body)
                        .foregroundColor(hLabelColor.link)
                }
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
            ForEach(travelInsuranceModel.policyCoinsuredPersons, id: \.id) { member in
                hRow {
                    hText(member.fullName, style: .body)
                    Spacer()
                    hText(member.personalNumber, style: .body)
                        .foregroundColor(hLabelColor.link)
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
        if travelInsuranceModel.policyCoinsuredPersons.count < travelInsuranceModel.maxNumberOfConisuredPersons {
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
