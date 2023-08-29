import Presentation
import SwiftUI
import hCore
import hCoreUI

struct InsuredMemberScreen: View {

    @ObservedObject var vm: InsuredMemberViewModel
    init(
        _ policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    ) {
        vm = .init(policyCoinsuredPerson)
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 4) {
                    fullNameField()
                    ssnField()
                }
            }
            .hWithoutDivider
        }
        .hDisableScroll
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButtonPrimary {
                        vm.submit()
                    } content: {
                        if vm.policyCoinsuredPerson == nil {
                            hText(L10n.generalSaveButton)
                        } else {
                            hText(L10n.TravelCertificate.confirmButtonChangeMember)
                        }
                    }

                    hButton.LargeButtonGhost {
                        vm.dismiss()
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle(vm.title)
    }

    private func fullNameField() -> some View {
        hRow {
            hFloatingTextField(
                masking: .init(type: .disabledSuggestion),
                value: $vm.fullName,
                equals: $vm.inputType,
                focusValue: .fullName,
                placeholder: L10n.fullNameText,
                error: $vm.fullNameError
            )
        }
        .noSpacing()
    }

    private func ssnField() -> some View {
        hRow {
            hFloatingTextField(
                masking: .init(type: .personalNumberCoInsured),
                value: $vm.personalNumber,
                equals: $vm.inputType,
                focusValue: .ssn,
                placeholder: "Personal number",
                error: $vm.personalNumberError
            )
        }
        .noSpacing()
    }
}

class InsuredMemberViewModel: ObservableObject {
    @Published var fullName: String
    @Published var personalNumber: String
    @Published var fullNameError: String?
    @Published var personalNumberError: String?
    @Published var inputType: TravelInsuranceFieldTypeInt? = .fullName
    @Published var validInput = false
    let title: String
    let policyCoinsuredPerson: PolicyCoinsuredPersonModel?
    @PresentableStore var store: TravelInsuranceStore
    init(_ model: PolicyCoinsuredPersonModel?) {
        if model == nil {
            self.title = L10n.TravelCertificate.changeMemberTitle
        } else {
            self.title = L10n.TravelCertificate.editMemberTitle
        }
        self.policyCoinsuredPerson = model
        self.fullName = model?.fullName ?? ""
        self.personalNumber = model?.personalNumber ?? ""
    }

    var personalNumberMaskeing: Masking {
        Masking(type: .personalNumberCoInsured)
    }

    func submit() {
        validate()
        if validInput {
            UIApplication.dismissKeyboard()
            let newPolicyCoInsured = PolicyCoinsuredPersonModel(fullName: fullName, personalNumber: personalNumber)
            if let policyCoinsuredPerson = policyCoinsuredPerson {
                dismiss()
                store.send(.updatePolicyCoInsured(policyCoinsuredPerson, with: newPolicyCoInsured))
            } else {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.store.send(
                        .setPolicyCoInsured(newPolicyCoInsured)
                    )
                }
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

    func dismiss() {
        store.send(.navigation(.dismissAddUpdateCoinsured))
    }
}
struct TravelInsuranceInsuredMemberScreen_Previews: PreviewProvider {
    static var previews: some View {
        InsuredMemberScreen(nil)
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
