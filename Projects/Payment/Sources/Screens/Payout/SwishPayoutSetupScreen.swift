import SwiftUI
import hCore
import hCoreUI

struct SwishPayoutSetupScreen: View {
    @StateObject private var vm = SwishPayoutSetupViewModel()
    @StateObject var router = NavigationRouter()
    let onSuccess: (() -> Void)?

    init(onSuccess: (() -> Void)? = nil) {
        self.onSuccess = onSuccess
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                //                connectionGraphic
                phoneNumberField
                confirmation
            }
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomContent
        }
        .disabled(vm.isLoading)
    }

    private var connectionGraphic: some View {
        PaymentConnectionGraphic(direction: .payout, provider: .swish)
            .padding(.vertical, .padding32)
    }

    private var phoneNumberField: some View {
        hSection {
            hFloatingTextField(
                masking: .init(type: .phoneNumber),
                value: $vm.phoneNumber,
                equals: $vm.focusedField,
                focusValue: .phoneNumber,
                placeholder: L10n.phoneNumberRowTitle,
                error: $vm.phoneNumberError
            )
        }
        .sectionContainerStyle(.transparent)
    }

    private var confirmation: some View {
        hSection {
            PaymentConfirmationCard(
                message: L10n.paymentsAddSwishPayoutInfo,
                isConfirmed: $vm.hasConfirmedNumber
            )
        }
        .sectionContainerStyle(.transparent)
    }

    private var bottomContent: some View {
        hSection {
            if let errorMessage = vm.errorMessage {
                PaymentErrorLabel(message: errorMessage)
            }
            saveButton
        }
        .padding(.vertical, .padding16)
        .sectionContainerStyle(.transparent)
    }

    private var saveButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalSaveButton)
        ) { [weak vm, onSuccess] in
            if let success = await vm?.save(), success {
                onSuccess?()
            }
        }
        .hButtonIsLoading(vm.isLoading)
        .disabled(vm.isSaveDisabled)
    }
}

extension SwishPayoutSetupScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: SwishPayoutSetupScreen.self)
    }
}

@MainActor
class SwishPayoutSetupViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var hasConfirmedNumber: Bool = false
    @Published var focusedField: SwishPayoutField?
    @Published var phoneNumberError: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let paymentService = hPaymentService()
    private let phoneNumberMasking = Masking(type: .phoneNumber)

    /// A payout destination is only as good as the member's word that it is theirs, so the
    /// confirmation gates saving rather than being validated after the fact.
    var isSaveDisabled: Bool {
        !hasConfirmedNumber
    }

    func save() async -> Bool {
        withAnimation {
            phoneNumberError = nil
            errorMessage = nil
        }

        if !validate() { return false }

        withAnimation { isLoading = true }
        defer { withAnimation { isLoading = false } }

        do {
            let result = try await paymentService.setupPaymentMethod(
                .swishPayout(
                    phoneNumber: phoneNumberMasking.unmaskedValue(text: phoneNumber)
                )
            )
            if let errorMessage = result.errorMessage {
                withAnimation { self.errorMessage = errorMessage }
                return false
            }
            return true
        } catch {
            withAnimation { errorMessage = error.localizedDescription }
            return false
        }
    }

    private func validate() -> Bool {
        guard phoneNumberMasking.isValid(text: phoneNumber) else {
            withAnimation {
                phoneNumberError = L10n.myInfoPhoneNumberMalformedError
                focusedField = .phoneNumber
            }
            return false
        }
        return true
    }
}

enum SwishPayoutField: hTextFieldFocusStateCompliant {
    case phoneNumber

    static var last: SwishPayoutField { .phoneNumber }

    var next: SwishPayoutField? {
        switch self {
        case .phoneNumber: return nil
        }
    }
}

#Preview {
    SwishPayoutSetupScreen()
        .environmentObject(NavigationRouter())
}
