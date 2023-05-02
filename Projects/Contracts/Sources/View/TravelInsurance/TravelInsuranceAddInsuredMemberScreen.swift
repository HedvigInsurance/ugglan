import SwiftUI
import hCore
import hCoreUI

struct TravelInsuranceAddInsuredMemberScreen: View {
    @State var fullName: String
    @State var personalNumber: String
    private let title: String
    init(_ policyCoinsuredPerson: PolicyCoinsuredPersonModel?) {
        self.fullName = policyCoinsuredPerson?.fullName ?? ""
        self.personalNumber = policyCoinsuredPerson?.personalNumber ?? ""
        self.title = policyCoinsuredPerson == nil ? "Add" : "Update"
    }
    
    var body: some View {
        hForm {
            hSection {
                hRow {
                    Text("FULL NAME")
                }
                hRow {
                    Text("ID NUMBER")
                }
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                //add/update member - should be same action
                UIApplication.dismissKeyboard()
            } content: {
                hText(title)
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 6)
        }.navigationTitle(title)
    }
}

struct TravelInsuranceAddInsuredMemberScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceAddInsuredMemberScreen(nil)
    }
}
