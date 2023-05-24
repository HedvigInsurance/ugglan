import Presentation
import SwiftUI
import hCore
import hCoreUI
struct TravelInsuranceInsuredMemberScreen: View {
    @State var fullName: String
    @State var personalNumber: String
    @State var fullNameError: String?
    @State var personalNumberError: String?
    @State var inputType: TravelInsuranceFieldTypeInt? = .fullName
    @State var validInput = false
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
            .focused($inputType, equals: .fullName)
            .hTextFieldError(fullNameError)
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
            .focused($inputType, equals: .ssn) {
                submit()
            }
            .hTextFieldError(personalNumberError)
            .hTextFieldOptions([])
        }
    }
    
    private func submit() {
        validate()
        if validInput {
            UIApplication.dismissKeyboard()
            store.send(
                .setPolicyCoInsured(PolicyCoinsuredPersonModel(fullName: fullName, personalNumber: personalNumber))
            )
        } else {
            
        }
    }
    
    private func validate(){
        if !personalNumberMaskeing.isValid(text: personalNumber) {
            personalNumberError = "Personal number should be valid"
        } else {
            personalNumberError = nil
        }
        if fullName.count < 2 {
            fullNameError = "Full Name should be at least 2 characters long"
        } else {
            fullNameError = nil
        }
        validInput = personalNumberError == nil && fullNameError == nil
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

enum TravelInsuranceFieldTypeInt: Int, hTextFieldFocusStateCompliant {
    static var last: TravelInsuranceFieldTypeInt {
        get{
            TravelInsuranceFieldTypeInt.ssn
        }
    }
    
    var next: TravelInsuranceFieldTypeInt? {
        get {
            switch self {
            case .fullName:
                return .ssn
            case .ssn:
                return nil
            }
        }
    }
    

    case fullName
    case ssn

}
