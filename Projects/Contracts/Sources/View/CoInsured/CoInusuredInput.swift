import Combine
import SwiftUI
import hCore
import hCoreUI

struct CoInusuredInput: View, KeyboardReadable {
    @State var fullName: String
    @State var firstName: String
    @State var lastName: String
    @State var SSN: String
    @State var type: CoInsuredInputType?
    @State var keyboardEnabled: Bool = false
    @PresentableStore var store: ContractStore
    let isDeletion: Bool
    let contractId: String
    @State var noSSN = false

    public init(
        isDeletion: Bool,
        fullName: String?,
        personalNumber: String?,
        contractId: String
    ) {
        self.isDeletion = isDeletion
        self.fullName = fullName ?? ""
        self.firstName = ""
        self.lastName = ""
        self.SSN = personalNumber ?? ""
        self.contractId = contractId
    }

    var body: some View {
        hForm {
            VStack(spacing: 4) {
                if isDeletion {
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
                } else {
                    Group {
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
                            .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                                keyboardEnabled = newIsKeyboardEnabled
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
                            .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                                keyboardEnabled = newIsKeyboardEnabled
                            }
                        }

                        hSection {
                            HStack(spacing: 4) {
                                hFloatingTextField(
                                    masking: Masking(type: .none),
                                    value: $firstName,
                                    equals: $type,
                                    focusValue: .firstName,
                                    placeholder: L10n.contractFirstName
                                )
                                .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                                    keyboardEnabled = newIsKeyboardEnabled
                                }
                                hFloatingTextField(
                                    masking: Masking(type: .none),
                                    value: $lastName,
                                    equals: $type,
                                    focusValue: .lastName,
                                    placeholder: L10n.contractLastName
                                )
                                .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                                    keyboardEnabled = newIsKeyboardEnabled
                                }
                            }
                        }
                        .sectionContainerStyle(.transparent)

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

                hSection {
                    hButton.LargeButton(type: .primary) {
                        if isDeletion {
                            store.coInsuredViewModel.removeCoInsured(name: fullName, personalNumber: SSN)
                            store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                        } else {
                            store.coInsuredViewModel.addCoInsured(name: firstName + " " + lastName, personalNumber: SSN)
                            store.send(.coInsuredNavigationAction(action: .addSuccess))
                        }
                    } content: {
                        hText(
                            isDeletion
                                ? L10n.removeConfirmationButton
                                : (saveIsDisabled ? L10n.generalSaveButton : L10n.generalAddButton)
                        )
                        .transition(.opacity.animation(.easeOut))
                    }
                }
                .padding(.top, 12)
                .disabled(saveIsDisabled && !isDeletion)

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

    var saveIsDisabled: Bool {
        var personalNumberValid = false
        var firstNameValid = false
        var lastNameValid = false
        if noSSN {
            personalNumberValid = Masking(type: .birthDateYYMMDD).isValid(text: SSN)
        } else {
            personalNumberValid = Masking(type: .personalNumber).isValid(text: SSN)
        }
        firstNameValid = Masking(type: .firstName).isValid(text: firstName)
        lastNameValid = Masking(type: .lastName).isValid(text: lastName)
        if personalNumberValid && firstNameValid && lastNameValid {
            return false
        }
        return true
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInput(isDeletion: false, fullName: "", personalNumber: "", contractId: "")
    }
}

enum CoInsuredInputType: hTextFieldFocusStateCompliant {
    static var last: CoInsuredInputType {
        return CoInsuredInputType.SSN
    }

    var next: CoInsuredInputType? {
        switch self {
        default:
            return nil
        }
    }

    case firstName
    case lastName
    case SSN
}

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
