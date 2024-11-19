import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View, KeyboardReadable {
    @StateObject var vm = SubmitClaimContractViewModel(phoneNumber: "")
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
                                vm.store.send(.phoneNumberRequest(phoneNumber: vm.phoneNumber))
                                UIApplication.dismissKeyboard()
                            }
                        } content: {
                            hText(vm.keyboardEnabled ? L10n.generalSaveButton : L10n.generalContinueButton)
                        }
                        .trackLoading(SubmitClaimStore.self, action: .postPhoneNumber)
                        .presentableStoreLensAnimation(.default)
                        .disabled(!(vm.enableContinueButton || vm.keyboardEnabled))

                    }
                    .padding(.bottom, .padding16)
                }
                .sectionContainerStyle(.transparent)
            }
            .claimErrorTrackerFor([.postContractSelect])
            .onReceive(keyboardPublisher) { keyboardHeight in
                vm.keyboardEnabled = keyboardHeight != nil
            }
    }
}

class SubmitClaimContractViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var enableContinueButton: Bool = false
    @Published var keyboardEnabled: Bool = false
    @Published var type: ClaimsFlowContactType?
    @Published var phoneNumberError: String?
    @PresentableStore var store: SubmitClaimStore
    var phoneNumberCancellable: AnyCancellable?

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self.enableContinueButton = phoneNumber.isValidPhone || phoneNumber.isEmpty
        phoneNumberCancellable = Publishers.CombineLatest($phoneNumber, $keyboardEnabled)
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { (phone, keyboardVisible) in
                let isValidPhone = phone.isValidPhone
                self.enableContinueButton = isValidPhone || phone.isEmpty
                self.phoneNumberError =
                    (self.enableContinueButton || keyboardVisible) ? nil : L10n.myInfoPhoneNumberMalformedError
            }
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
