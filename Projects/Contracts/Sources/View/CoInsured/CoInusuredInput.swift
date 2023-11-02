import Combine
import SwiftUI
import hCore
import hCoreUI

struct CoInusuredInput: View {
    @State var fullName: String
    @State var firstName: String
    @State var lastName: String
    @State var SSN: String
    @State var type: CoInsuredInputType?
    @State var keyboardEnabled: Bool = false
    @State var nameFetchedFromSSN: Bool = false
    @PresentableStore var store: ContractStore
    let isDeletion: Bool
    let contractId: String
    @State var noSSN = false

    public init(
        isDeletion: Bool,
        fullName: String?,
        SSN: String?,
        contractId: String
    ) {
        self.isDeletion = isDeletion
        self.fullName = fullName ?? ""
        self.firstName = ""
        self.lastName = ""
        self.SSN = SSN ?? ""
        self.contractId = contractId
    }

    var body: some View {
        hForm {
            VStack(spacing: 4) {
                if isDeletion {
                    deleteCoInsuredFields
                } else {
                    addCoInsuredFields
                }
                hSection {
                    LoadingButtonWithContent(ContractStore.self, .fetchNameFromSSN) {
                        if !(buttonIsDisabled || nameFetchedFromSSN || noSSN) {
                            /* TODO: FETCH SSN MUTATION*/
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                //on success - show name field
                                // else show error
                                nameFetchedFromSSN = true
                                firstName = "Hedvig"
                                lastName = "AB"
                            }
                        } else if isDeletion {
                            store.coInsuredViewModel.removeCoInsured(name: fullName, personalNumber: SSN)
                            store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                        } else if nameFetchedFromSSN || noSSN {
                            store.coInsuredViewModel.addCoInsured(name: firstName + " " + lastName, personalNumber: SSN)
                            store.send(.coInsuredNavigationAction(action: .addSuccess))
                        }
                    } content: {
                        hText(buttonDisplayText)
                            .transition(.opacity.animation(.easeOut))
                    }
                }
                .padding(.top, 12)
                .disabled(buttonIsDisabled && !isDeletion)

                hButton.LargeButton(type: .ghost) {
                    store.send(.coInsuredNavigationAction(action: .dismissEdit))
                } content: {
                    hText(L10n.generalCancelButton)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }

    var buttonDisplayText: String {
        if isDeletion {
            return L10n.removeConfirmationButton
        } else if nameFetchedFromSSN {
            return L10n.contractAddCoinsured
        } else if Masking(type: .personalNumber).isValid(text: SSN) {
            return L10n.contractSsnFetchInfo
        } else if buttonIsDisabled || noSSN {
            return L10n.generalSaveButton
        }
        return ""
    }

    @ViewBuilder
    var addCoInsuredFields: some View {
        Group {
            ZStack {
                if noSSN {
                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .birthDateYYMMDD),
                            value: $SSN,
                            equals: $type,
                            focusValue: .SSN,
                            placeholder: L10n.contractBirthDate
                        )
                    }
                    .onAppear {
                        keyboardEnabled = false
                    }
                } else {
                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .personalNumber),
                            value: $SSN,
                            equals: $type,
                            focusValue: .SSN,
                            placeholder: L10n.contractPersonalIdentity
                        )
                    }
                }
            }

            if nameFetchedFromSSN || noSSN {
                hSection {
                    HStack(spacing: 4) {
                        hFloatingTextField(
                            masking: Masking(type: .firstName),
                            value: $firstName,
                            equals: $type,
                            focusValue: .firstName,
                            placeholder: L10n.contractFirstName
                        )
                        hFloatingTextField(
                            masking: Masking(type: .lastName),
                            value: $lastName,
                            equals: $type,
                            focusValue: .lastName,
                            placeholder: L10n.contractLastName
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            }

            hSection {
                Toggle(isOn: $noSSN.animation(.default)) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(L10n.contractAddCoinsuredNoSsn, style: .body)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        noSSN.toggle()
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .sectionContainerStyle(.opaque)
        }
        .hFieldSize(.small)
    }

    @ViewBuilder
    var deleteCoInsuredFields: some View {
        if fullName != "" && SSN != "" {
            hSection {
                hFloatingField(
                    value: fullName,
                    placeholder: L10n.fullNameText,
                    onTap: {}
                )
            }
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.lockSmall.image)
                    .foregroundColor(hTextColor.secondary)
            }
            .disabled(true)
            .sectionContainerStyle(.transparent)

            hSection {
                hFloatingField(
                    value: SSN,
                    placeholder: L10n.TravelCertificate.personalNumber,
                    onTap: {}
                )
            }
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.lockSmall.image)
                    .foregroundColor(hTextColor.secondary)
            }
            .disabled(true)
            .sectionContainerStyle(.transparent)
        }
    }

    var buttonIsDisabled: Bool {
        var personalNumberValid = false
        if noSSN {
            personalNumberValid = Masking(type: .birthDateYYMMDD).isValid(text: SSN)
            let firstNameValid = Masking(type: .firstName).isValid(text: firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: lastName)
            if personalNumberValid && firstNameValid && lastNameValid {
                return false
            }
        } else {
            personalNumberValid = Masking(type: .personalNumber).isValid(text: SSN)
            if personalNumberValid {
                return false
            }
        }
        return true
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInput(isDeletion: false, fullName: "", SSN: "", contractId: "")
    }
}

enum CoInsuredInputType: hTextFieldFocusStateCompliant {
    static var last: CoInsuredInputType {
        return CoInsuredInputType.lastName
    }

    var next: CoInsuredInputType? {
        switch self {
        case .SSN:
            return .firstName
        case .firstName:
            return .lastName
        case .lastName:
            return nil
        }
    }

    case firstName
    case lastName
    case SSN
}
