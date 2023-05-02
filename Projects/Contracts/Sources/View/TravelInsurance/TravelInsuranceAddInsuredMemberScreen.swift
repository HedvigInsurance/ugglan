import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceAddInsuredMemberScreen: View {
    @State var fullName: String
    @State var personalNumber: String
    private let title: String
    init(
        _ policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    ) {
        self.fullName = policyCoinsuredPerson?.fullName ?? ""
        self.personalNumber = policyCoinsuredPerson?.personalNumber ?? ""
        self.title = policyCoinsuredPerson == nil ? "Add" : "Update"
    }

    var body: some View {
        hForm {
            hSection {
                hRow {
                    hTextField(
                        masking: Masking(type: .none),
                        value: $fullName,
                        placeholder: L10n.fullNameText
                    )
                    .hTextFieldOptions([])
                }
                hRow {
                    hTextField(
                        masking: Masking(type: .personalNumber),
                        value: $personalNumber
                    )
                    .hTextFieldOptions([])
                }
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                //add/update member - should be same action
                UIApplication.dismissKeyboard()

                let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
                store.send(
                    .setPolicyConInsured(PolicyCoinsuredPersonModel(fullName: fullName, personalNumber: personalNumber))
                )
                store.send(.dismiss)
            } content: {
                hText(title)
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 6)
        }
        .navigationTitle(title)
    }
}

struct TravelInsuranceAddInsuredMemberScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceAddInsuredMemberScreen(nil)
    }
}
