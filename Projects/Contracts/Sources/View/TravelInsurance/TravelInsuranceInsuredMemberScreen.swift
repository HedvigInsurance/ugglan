import Presentation
import SwiftUI
import hCore
import hCoreUI
struct TravelInsuranceInsuredMemberScreen: View {
    @State var fullName: String
    @State var personalNumber: String
    @State var error: String? {
        didSet{
            showError = error != nil && error != ""
        }
    }
    
    @State var showError = false

    @State var validInput = true
    var personalNumberMaskeing: Masking {
        Masking(type: .personalNumber)
    }
    
    private let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
    private let title: String
    private let policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    init(
        _ policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    ) {
        self.title = L10n.TravelCertificate.includedMembersTitle
        self.policyCoinsuredPerson = policyCoinsuredPerson
        self.fullName = policyCoinsuredPerson?.fullName ?? ""
        self.personalNumber = policyCoinsuredPerson?.personalNumber ?? ""
        
    }

    var body: some View {
        hForm {
            hSection {
                fullNameField()
                ssnField()
            }
            .navigationTitle(title)
            .alert(isPresented: $showError) {
                Alert(title: Text(self.error ?? ""), dismissButton: .default(Text("Ok")))
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButtonFilled {
                    submit()
                } content: {
                    hText(L10n.TravelCertificate.addMember)
                }

                hButton.SmallButtonText {
                    store.send(.navigation(.dismissAddUpdateCoinsured))
                } content: {
                    hText(L10n.generalCancelButton)
                }


            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 6)
        }

    }
    
    @ViewBuilder
    private func fullNameField() -> some View {
        hRow {
            hTextField(
                masking: Masking(type: .disabledSuggestion),
                value: $fullName,
                placeholder: L10n.fullNameText
            )
            .hTextFieldOptions([])
        }
    }
    
    @ViewBuilder
    private func ssnField() -> some View {
        hRow {
            hTextField(
                masking: Masking(type: .personalNumber),
                value: $personalNumber
            )
            .hTextFieldOptions([])
        }
    }
    
    private func submit() {
        validate()
        if error == nil {
            UIApplication.dismissKeyboard()
            store.send(
                .setPolicyCoInsured(PolicyCoinsuredPersonModel(fullName: fullName, personalNumber: personalNumber))
            )
        } else {
            
        }
    }
    
    private func validate(){
        error = nil
//        var errors = [String]()
//        if !personalNumberMaskeing.isValid(text: personalNumber) {
//            errors.append("Personal number should be valid")
//        }
//        if fullName.count < 2 {
//            errors.append("Full Name should be at least 2 characters long")
//        }
//        error = errors.joined(separator: "\n\r")
    }
}

struct TravelInsuranceInsuredMemberScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceInsuredMemberScreen(nil)
    }
}

enum TravelInsuranceFieldType: String, Hashable, hTextFieldFocusStateCompliant {
    static var last: TravelInsuranceFieldType {
        get {
            return .personalNumber
        }
    }
    
    var next: TravelInsuranceFieldType? {
        get {
            switch self {
            case .fullName:
                return .personalNumber
            case .personalNumber:
                return nil
            }
            
        }
    }
    
    case fullName
    case personalNumber
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}

enum TravelInsuranceFieldTypeInt: Int {

    case fullName
    case personalNumber

}
