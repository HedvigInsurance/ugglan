import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CoInusuredInput: View {
    @PresentableStore var store: ContractStore
    @ObservedObject var vm: CoInusuredInputViewModel

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
                if vm.isDeletion {
                    deleteCoInsuredFields
                } else {
                    addCoInsuredFields
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        if !(buttonIsDisabled || vm.nameFetchedFromSSN || vm.noSSN) {
                            Task {
                                await vm.getNameFromSSN(SSN: vm.SSN)
                            }
                        } else if vm.isDeletion {
                            store.coInsuredViewModel.removeCoInsured(
                                firstName: vm.firstName,
                                lastName: vm.lastName,
                                personalNumber: vm.SSN
                            )
                            store.send(.coInsuredNavigationAction(action: .deletionSuccess))
                        } else if vm.nameFetchedFromSSN || vm.noSSN {
                            store.coInsuredViewModel.addCoInsured(
                                firstName: vm.firstName,
                                lastName: vm.lastName,
                                personalNumber: vm.SSN
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
                .disabled(buttonIsDisabled && !vm.isDeletion)

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
                        vm.SSN = ""
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
        if vm.isDeletion {
            return L10n.removeConfirmationButton
        } else if vm.nameFetchedFromSSN {
            return L10n.contractAddCoinsured
        } else if Masking(type: .personalNumber).isValid(text: vm.SSN) && !vm.noSSN {
            return L10n.contractSsnFetchInfo
        } else {
            return L10n.generalSaveButton
        }
    }

    @ViewBuilder
    var addCoInsuredFields: some View {
        Group {
            //<<<<<<< ours
            if vm.noSSN {
                hSection {
                    hFloatingTextField(
                        masking: Masking(type: .birthDateYYMMDD),
                        value: $vm.SSN,
                        equals: $vm.type,
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
                        value: $vm.SSN,
                        equals: $vm.type,
                        focusValue: .SSN,
                        placeholder: L10n.contractPersonalIdentity
                    )
                }
                .disabled(vm.isLoading)
                .sectionContainerStyle(.transparent)
                .onChange(of: vm.SSN) { newValue in
                    vm.nameFetchedFromSSN = false
                }
            }

            if vm.nameFetchedFromSSN || vm.noSSN {
                hSection {
                    HStack(spacing: 4) {
                        hFloatingTextField(
                            masking: Masking(type: .firstName),
                            value: $vm.firstName,
                            equals: $vm.type,
                            focusValue: .firstName,
                            placeholder: L10n.contractFirstName
                        )
                        hFloatingTextField(
                            masking: Masking(type: .lastName),
                            value: $vm.lastName,
                            equals: $vm.type,
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
        if vm.firstName != "" && vm.lastName != "" && vm.SSN != "" {
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
                    value: vm.SSN,
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
            personalNumberValid = Masking(type: .birthDateYYMMDD).isValid(text: vm.SSN)
            let firstNameValid = Masking(type: .firstName).isValid(text: vm.firstName)
            let lastNameValid = Masking(type: .lastName).isValid(text: vm.lastName)
            if personalNumberValid && firstNameValid && lastNameValid {
                return false
            }
        } else {
            personalNumberValid = Masking(type: .personalNumber).isValid(text: vm.SSN)
            if personalNumberValid {
                return false
            }
        }
        return true
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInput(vm: .init(coInsuredModel: .init(), isDeletion: false, contractId: ""))
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

class CoInusuredInputViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var noSSN = false
    @Published var SSNError: Error?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorView: Bool = false
    @Published var enterManually: Bool = false
    @Published var SSN: String
    @Published var type: CoInsuredInputType?
    let isDeletion: Bool
    let contractId: String
    @Inject var octopus: hOctopus

    init(
        coInsuredModel: CoInsuredModel,
        isDeletion: Bool,
        contractId: String
    ) {
        self.firstName = coInsuredModel.firstName ?? ""
        self.lastName = coInsuredModel.lastName ?? ""
        self.SSN = coInsuredModel.SSN ?? ""
        self.isDeletion = isDeletion
        self.contractId = contractId
    }

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.SSNError = nil
            self.isLoading = true
        }
        do {
            let data = try await withCheckedThrowingContinuation {
                (
                    continuation: CheckedContinuation<
                        OctopusGraphQL.PersonalInformationQuery.Data.PersonalInformation, Error
                    >
                ) -> Void in
                let SSNInput = OctopusGraphQL.PersonalInformationInput(personalNumber: SSN)
                self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.PersonalInformationQuery(input: SSNInput),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { value in
                        if let data = value.personalInformation {
                            continuation.resume(with: .success(data))
                        }
                    }
                    .onError { graphQLError in

                        continuation.resume(throwing: graphQLError)
                    }
            }
            withAnimation {
                self.firstName = data.firstName
                self.lastName = data.lastName
                self.nameFetchedFromSSN = true
            }

        } catch let exception {
            if let exception = exception as? GraphQLError {
                switch exception {
                case .graphQLError:
                    self.enterManually = true
                case .otherError:
                    self.enterManually = false
                }
            }
            withAnimation {
                self.SSNError = exception
                self.showErrorView = true
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
