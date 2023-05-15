import Presentation
import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceInsuredMemberScreen: View {
    @State var fullName: String
    @State var personalNumber: String
    private let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
    private let title: String
    private let policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    init(
        _ policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    ) {
        self.title = policyCoinsuredPerson == nil ? "Add" : "Update"
        
        self.policyCoinsuredPerson = policyCoinsuredPerson
        self.fullName = policyCoinsuredPerson?.fullName ?? ""
        self.personalNumber = policyCoinsuredPerson?.personalNumber ?? ""
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
            VStack(spacing: 8) {
                hButton.LargeButtonFilled {
                    UIApplication.dismissKeyboard()
                    store.send(
                        .setPolicyCoInsured(PolicyCoinsuredPersonModel(fullName: fullName, personalNumber: personalNumber))
                    )
                } content: {
                    hText(title)
                }
                
                hButton.SmallButtonText {
                    store.send(.navigation(.dismissAddUpdateCoinsured))
                } content: {
                    hText("Cancel")
                }

                
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 6)
        }
        .navigationTitle(title)
    }
}

struct TravelInsuranceInsuredMemberScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceInsuredMemberScreen(nil)
    }
}
