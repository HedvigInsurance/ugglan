import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimContactScreen: View, KeyboardReadable {
    @StateObject var vm = SubmitClaimContractViewModel(phoneNumber: "")
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    public init(
        model: FlowClaimPhoneNumberStepModel
    ) {
        _vm = StateObject(wrappedValue: SubmitClaimContractViewModel(phoneNumber: model.phoneNumber))
    }

    public var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    L10n.claimsConfirmNumberTitle,
                    alignment: .leading
                )
            )
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding16) {
                        hFloatingTextField(
                            masking: Masking(type: .digits),
                            value: $vm.phoneNumber,
                            equals: $vm.type,
                            focusValue: .phoneNumber,
                            placeholder: L10n.phoneNumberRowTitle,
                            error: $vm.phoneNumberError
                        )
                        hButton(
                            .large,
                            .primary,
                            content: .init(
                                title: vm.keyboardEnabled ? L10n.generalSaveButton : L10n.generalContinueButton
                            ),
                            {
                                if vm.keyboardEnabled {
                                    withAnimation {
                                        UIApplication.dismissKeyboard()
                                    }
                                } else {
                                    Task {
                                        if let model = claimsNavigationVm.phoneNumberModel {
                                            let step = await vm.phoneNumberRequest(
                                                context: claimsNavigationVm.currentClaimContext ?? "",
                                                model: model
                                            )

                                            if let step {
                                                claimsNavigationVm.navigate(data: step)
                                            }
                                        }
                                    }
                                    UIApplication.dismissKeyboard()
                                }
                            }
                        )
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
            .claimErrorTrackerForState($vm.viewState)
    }
}

@MainActor
class SubmitClaimContractViewModel: ObservableObject {
    @Published var phoneNumber: String {
        didSet {
            let isValidPhone = phoneNumber.isValidPhone
            enableContinueButton = isValidPhone || phoneNumber.isEmpty
            phoneNumberError =
                (enableContinueButton || keyboardEnabled) ? nil : L10n.myInfoPhoneNumberMalformedError
        }
    }

    @Published var enableContinueButton: Bool = false
    @Published var keyboardEnabled: Bool = false
    @Published var type: ClaimsFlowContactType?
    @Published var phoneNumberError: String?
    private let service = SubmitClaimService()
    @Published var viewState: ProcessingState = .success
    private var phoneNumberCancellable: AnyCancellable?
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        enableContinueButton = phoneNumber.isValidPhone || phoneNumber.isEmpty
        phoneNumberCancellable = Publishers.CombineLatest($phoneNumber, $keyboardEnabled)
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] phone, keyboardVisible in
                let isValidPhone = phone.isValidPhone
                self?.enableContinueButton = isValidPhone || phone.isEmpty
                self?.phoneNumberError =
                    (self?.enableContinueButton ?? false || keyboardVisible)
                    ? nil : L10n.myInfoPhoneNumberMalformedError
            }
    }

    @MainActor
    func phoneNumberRequest(
        context: String,
        model: FlowClaimPhoneNumberStepModel
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
        ClaimsFlowContactType.phoneNumber
    }

    var next: ClaimsFlowContactType? {
        switch self {
        default:
            return nil
        }
    }

    case phoneNumber
}

#Preview {
    SubmitClaimContactScreen(model: .init(phoneNumber: ""))
}
