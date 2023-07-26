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
        Masking(type: .personalNumberCoInsured)
    }

    private let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
    private let title: String
    private let policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    init(
        _ policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    ) {
        if policyCoinsuredPerson == nil {
            self.title = L10n.TravelCertificate.changeMemberTitle
        } else {
            self.title = L10n.TravelCertificate.editMemberTitle
        }
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
                hButton.LargeButtonPrimary {
                    submit()
                } content: {
                    if policyCoinsuredPerson == nil {
                        hText(L10n.generalContinueButton)
                    } else {
                        hText(L10n.TravelCertificate.confirmButtonChangeMember)
                    }
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
            .hTextFieldOptions([.minimumHeight(height: 40)])
        }
    }

    @ViewBuilder
    private func ssnField() -> some View {
        hRow {
            hTextField(
                masking: Masking(type: .personalNumberCoInsured),
                value: $personalNumber
            )
            .focused($inputType, equals: .ssn) {
                submit()
            }
            .hTextFieldError(personalNumberError)
            .hTextFieldOptions([.minimumHeight(height: 40)])
        }
    }

    private func submit() {
        validate()
        if validInput {
            UIApplication.dismissKeyboard()
            let newPolicyCoInsured = PolicyCoinsuredPersonModel(fullName: fullName, personalNumber: personalNumber)
            if let policyCoinsuredPerson {
                store.send(.updatePolicyCoInsured(policyCoinsuredPerson, with: newPolicyCoInsured))
            } else {
                store.send(
                    .setPolicyCoInsured(newPolicyCoInsured)
                )
            }
        } else {

        }
    }

    private func validate() {
        withAnimation {
            if !personalNumberMaskeing.isValid(text: personalNumber) {
                personalNumberError = L10n.TravelCertificate.ssnErrorLabel
            } else {
                personalNumberError = nil
            }
            if fullName.count < 2 {
                fullNameError = L10n.TravelCertificate.nameErrorLabel
            } else {
                fullNameError = nil
            }
            validInput = personalNumberError == nil && fullNameError == nil
        }
    }
}

struct TravelInsuranceInsuredMemberScreen_Previews: PreviewProvider {
    static var previews: some View {
        TravelInsuranceInsuredMemberScreen(nil)
    }
}

enum TravelInsuranceFieldType: String, Hashable, hTextFieldFocusStateCompliant {
    static var last: TravelInsuranceFieldType {
        return .personalNumber
    }

    var next: TravelInsuranceFieldType? {
        switch self {
        case .fullName:
            return .personalNumber
        case .personalNumber:
            return nil
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
        TravelInsuranceFieldTypeInt.ssn
    }

    var next: TravelInsuranceFieldTypeInt? {
        switch self {
        case .fullName:
            return .ssn
        case .ssn:
            return nil
        }
    }

    case fullName
    case ssn

}
