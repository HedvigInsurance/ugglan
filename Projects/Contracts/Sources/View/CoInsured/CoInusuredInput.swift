import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInusuredInput: View, KeyboardReadable {
    @State var SSN: String
    @State var type: CoInsuredInputType?
    @State var keyboardEnabled: Bool = false
    @PresentableStore var store: ContractStore
    let isDeletion: Bool
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel

    public init(
        isDeletion: Bool,
        firstName: String? = nil,
        lastName: String? = nil,
        SSN: String?,
        contractId: String
    ) {
        self.isDeletion = isDeletion
        self.SSN = SSN ?? ""
        self.contractId = contractId

        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        vm.firstName = firstName ?? ""
        vm.lastName = lastName ?? ""
    }

    var body: some View {
        mainView
    }
    
    @ViewBuilder
    var mainView: some View {
        hForm {
            VStack(spacing: 4) {
                if isDeletion {
                    deleteCoInsuredFields
                } else {
                    addCoInsuredFields
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                            Task {
                                await vm.getNameFromSSN(SSN: SSN)
                            }
                        } else if isDeletion {
                            store.coInsuredViewModel.removeCoInsured(
                                firstName: vm.firstName,
                                lastName: vm.lastName,
                                personalNumber: SSN
                            )
                            store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                        } else if vm.nameFetchedFromSSN || vm.noSSN {
                            store.coInsuredViewModel.addCoInsured(
                                firstName: vm.firstName,
                                lastName: vm.lastName,
                                personalNumber: SSN
                            )
                            store.send(.coInsuredNavigationAction(action: .addSuccess))
                        }
                    } content: {
                        hText(buttonDisplayText)
                            .transition(.opacity.animation(.easeOut))
                    }
                    .hButtonIsLoading(vm.isLoading)
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
        .onAppear {
            vm.SSNError = nil
            vm.nameFetchedFromSSN = false
            vm.noSSN = false
        }
    }

    var buttonDisplayText: String {
        if isDeletion {
            return L10n.removeConfirmationButton
        } else if vm.nameFetchedFromSSN {
            return L10n.contractAddCoinsured
        } else if Masking(type: .personalNumber).isValid(text: SSN) && !vm.noSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.generalSaveButton
        }
    }

    @ViewBuilder
    var addCoInsuredFields: some View {
        Group {
            if vm.noSSN {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .birthDateYYMMDD),
                        value: $SSN,
                        equals: $type,
                        focusValue: .SSN,
                        placeholder: L10n.contractBirthDate
                    )
                }
                .sectionContainerStyle(.transparent)
                .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                    keyboardEnabled = newIsKeyboardEnabled
                }
                .onAppear {
                    vm.nameFetchedFromSSN = false
                }
            } else {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .personalNumber),
                        value: $SSN,
                        equals: $type,
                        focusValue: .SSN,
                        placeholder: L10n.contractPersonalIdentity,
                        error: $vm.SSNError
                    )
                }
                .disabled(vm.isLoading)
                .sectionContainerStyle(.transparent)
                .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                    keyboardEnabled = newIsKeyboardEnabled
                }
                .onChange(of: SSN) { newValue in
                    vm.nameFetchedFromSSN = false
                }
            }

            if vm.nameFetchedFromSSN || vm.noSSN {
                hSection {
                    HStack(spacing: 4) {
                        hFloatingTextField(
                            masking: Masking(type: .firstName),
                            value: $vm.firstName,
                            equals: $type,
                            focusValue: .firstName,
                            placeholder: L10n.contractFirstName
                        )
                        .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                            keyboardEnabled = newIsKeyboardEnabled
                        }
                        hFloatingTextField(
                            masking: Masking(type: .lastName),
                            value: $vm.lastName,
                            equals: $type,
                            focusValue: .lastName,
                            placeholder: L10n.contractLastName
                        )
                        .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                            keyboardEnabled = newIsKeyboardEnabled
                        }
                    }
                }
                .disabled(vm.nameFetchedFromSSN)
                .sectionContainerStyle(.transparent)
            }

            hSection {
                Toggle(isOn: $vm.noSSN.animation(.default)) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(L10n.contractAddCoinsuredNoSsn, style: .body)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        vm.noSSN.toggle()
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
        if vm.firstName != "" && vm.lastName != "" && SSN != "" {
            hSection {
                hFloatingField(
                    value: vm.firstName + vm.lastName,
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
        if vm.noSSN {
            personalNumberValid = Masking(type: .birthDateYYMMDD).isValid(text: SSN)
            let firstNameValid = Masking(type: .firstName).isValid(text: vm.firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: vm.lastName)
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
        CoInusuredInput(isDeletion: false, SSN: "", contractId: "")
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
