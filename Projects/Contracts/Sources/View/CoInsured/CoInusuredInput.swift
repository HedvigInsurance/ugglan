import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInusuredInput: View {
    @State var SSN: String
    @State var type: CoInsuredInputType?
    @State var keyboardEnabled: Bool = false
    @PresentableStore var store: ContractStore
    let actionType: CoInsuredAction
    let contractId: String
    @ObservedObject var vm: InsuredPeopleNewScreenModel

    public init(
        actionType: CoInsuredAction,
        fullName: String? = nil,
        SSN: String?,
        contractId: String
    ) {
        self.actionType = actionType
        self.SSN = SSN ?? ""
        self.contractId = contractId

        let store: ContractStore = globalPresentableStoreContainer.get()
        vm = store.coInsuredViewModel
        vm.previousName = vm.fullName
        vm.previousSSN = SSN ?? ""
        vm.fullName = fullName ?? ""
        vm.SSNError = nil
        vm.nameFetchedFromSSN = false
        vm.noSSN = false
    }

    var body: some View {
        if vm.showErrorView {
            errorView
        } else {
            mainView
        }
    }
    
    @ViewBuilder
    var mainView: some View {
        hForm {
            VStack(spacing: 4) {
                if actionType == .delete {
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
                        } else if actionType == .delete {
                            store.coInsuredViewModel.removeCoInsured(
                                fullName: vm.fullName,
                                personalNumber: SSN
                            )
                            store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                        } else if vm.nameFetchedFromSSN || vm.noSSN {
                            vm.fullName = vm.firstName + " " + vm.lastName
                            
                            if actionType == .edit {
                                store.coInsuredViewModel.editCoInsured(
                                    fullName: vm.fullName,
                                    personalNumber: SSN
                                )
                            } else {
                                store.coInsuredViewModel.addCoInsured(
                                    fullName: vm.fullName,
                                    personalNumber: SSN
                                )
                            }
                            store.send(.coInsuredNavigationAction(action: .addSuccess))
                        }
                    } content: {
                        hText(buttonDisplayText)
                            .transition(.opacity.animation(.easeOut))
                    }
                    .hButtonIsLoading(vm.isLoading)
                }
                .padding(.top, 12)
                .disabled(buttonIsDisabled && !(actionType == .delete))
                
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
    
    @ViewBuilder
    var errorView: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
                
                VStack {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(vm.SSNError?.localizedDescription ?? "")
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.enterManually {
                    hButton.LargeButton(type: .primary) {
                        vm.showErrorView = false
                        vm.noSSN = true
                        SSN = ""
                    } content: {
                        hText(L10n.coinsuredEnterManuallyButton)
                    }
                } else {
                    hButton.LargeButton(type: .primary) {
                        vm.showErrorView = false
                    } content: {
                        hText(L10n.generalRetry)
                    }
                }
                hButton.LargeButton(type: .ghost) {
                } content: {
                    hText(L10n.generalCancelButton)
                }
                
            }
            .padding(16)
        }
    }
    
    var buttonDisplayText: String {
        if actionType == .delete {
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
                        placeholder: L10n.contractPersonalIdentity
                    )
                }
                .disabled(vm.isLoading)
                .sectionContainerStyle(.transparent)
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
                        hFloatingTextField(
                            masking: Masking(type: .lastName),
                            value: $vm.lastName,
                            equals: $type,
                            focusValue: .lastName,
                            placeholder: L10n.contractLastName
                        )
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
        CoInusuredInput(actionType: .add, SSN: "", contractId: "")
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
