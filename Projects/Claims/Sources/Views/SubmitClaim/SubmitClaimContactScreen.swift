import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View, KeyboardReadable {
    @StateObject var vm = SubmitClaimContractViewModel(phoneNumber: "")
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel

    public init(
        model: FlowClaimPhoneNumberStepModel
    ) {
        self._vm = StateObject(wrappedValue: SubmitClaimContractViewModel(phoneNumber: model.phoneNumber))
    }

    public var body: some View {
        hForm {}
            .hFormTitle(title: .init(.small, .displayXSLong, L10n.claimsConfirmNumberTitle))
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 16) {
                        hFloatingTextField(
                            masking: Masking(type: .digits),
                            value: $vm.phoneNumber,
                            equals: $vm.type,
                            focusValue: .phoneNumber,
                            placeholder: L10n.phoneNumberRowTitle,
                            error: $vm.phoneNumberError
                        )
                        hButton.LargeButton(type: .primary) {
                            if vm.keyboardEnabled {
                                withAnimation {
                                    UIApplication.dismissKeyboard()
                                }
                            } else {
                                Task {
                                    let step = await vm.phoneNumberRequest(
                                        context: claimsNavigationVm.currentClaimContext ?? "",
                                        model: claimsNavigationVm.phoneNumberModel
                                    )

                                    if let step {
                                        claimsNavigationVm.navigate(data: step)
                                    }
                                }
                                UIApplication.dismissKeyboard()
                            }
                        } content: {
                            hText(vm.keyboardEnabled ? L10n.generalSaveButton : L10n.generalContinueButton)
                        }
                        .disabled(!(vm.enableContinueButton || vm.keyboardEnabled))
                        .hButtonIsLoading(vm.viewState == .loading)

                    }
                    .padding(.bottom, .padding16)
                }
                .sectionContainerStyle(.transparent)
            }
            .onReceive(keyboardPublisher) { keyboardHeight in
                vm.keyboardEnabled = keyboardHeight != nil
            }
    }
}

class SubmitClaimContractViewModel: ObservableObject {
    @Published var phoneNumber: String {
        didSet {
            let isValidPhone = phoneNumber.isValidPhone
            self.enableContinueButton = isValidPhone || phoneNumber.isEmpty
            self.phoneNumberError =
                (self.enableContinueButton || keyboardEnabled) ? nil : L10n.myInfoPhoneNumberMalformedError
        }
    }
    @Published var enableContinueButton: Bool = false
    @Published var keyboardEnabled: Bool = false
    @Published var type: ClaimsFlowContactType?
    @Published var phoneNumberError: String?
    @Inject private var service: SubmitClaimClient
    @Published var viewState: ProcessingState = .success

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self.enableContinueButton = phoneNumber.isValidPhone || phoneNumber.isEmpty
    }

    @MainActor
    func phoneNumberRequest(
        context: String,
        model: FlowClaimPhoneNumberStepModel?
    ) async -> SubmitClaimStepResponse? {
        withAnimation {
            self.viewState = .loading
        }
        do {
            let data = try await service.updateContact(phoneNumber: phoneNumber, context: context, model: model)
            withAnimation {
                self.viewState = .success
            }
            return data
        } catch let exception {
            withAnimation {
                self.viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        return nil
    }
}

enum ClaimsFlowContactType: hTextFieldFocusStateCompliant {
    static var last: ClaimsFlowContactType {
        return ClaimsFlowContactType.phoneNumber
    }

    var next: ClaimsFlowContactType? {
        switch self {
        default:
            return nil
        }
    }

    case phoneNumber
}

struct SubmitClaimContactScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimContactScreen(model: .init(id: "", phoneNumber: ""))
    }
}
