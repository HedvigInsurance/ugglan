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
                        .disableOn(SubmitClaimStore.self, [.postPhoneNumber])
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
    //    var phoneNumberCancellable: AnyCancellable?
    @Inject private var service: SubmitClaimClient

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self.enableContinueButton = phoneNumber.isValidPhone || phoneNumber.isEmpty
        /* TODO: IMPLEMENT */
        //        phoneNumberCancellable = Publishers.CombineLatest($phoneNumber, $keyboardEnabled)
        //            .receive(on: RunLoop.main)
        //            .sink { _ in
        //            } receiveValue: { (phone, keyboardVisible) in
        //                let isValidPhone = phone.isValidPhone
        //                self.enableContinueButton = isValidPhone || phone.isEmpty
        //                self.phoneNumberError =
        //                    (self.enableContinueButton || keyboardVisible) ? nil : L10n.myInfoPhoneNumberMalformedError
        //            }
    }

    @MainActor
    func phoneNumberRequest(
        context: String,
        model: FlowClaimPhoneNumberStepModel?
    ) async -> SubmitClaimStepResponse? {
        do {
            let data = try await service.updateContact(phoneNumber: phoneNumber, context: context, model: model)

            return data
        } catch let exception {}
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
