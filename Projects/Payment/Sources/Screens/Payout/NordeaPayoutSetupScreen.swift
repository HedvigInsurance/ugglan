import Combine
import SwiftUI
import hCore
import hCoreUI

struct NordeaPayoutSetupScreen: View {
    @State private var vm = NordeaPayoutSetupViewModel()
    @StateObject var router = NavigationRouter()
    let onSuccess: (() -> Void)?

    init(onSuccess: (() -> Void)? = nil) {
        self.onSuccess = onSuccess
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                accountField
            }
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomContent
        }
        .disabled(vm.isLoading)
    }

    private var accountField: some View {
        hSection {
            hFloatingTextField(
                masking: .init(type: .bankAccountNumber),
                value: $vm.accountNumber,
                equals: $vm.focusedField,
                focusValue: .account,
                placeholder: placeholder,
                error: $vm.accountError
            )
        }
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
            if let success = await vm?.save() {
                if success {
                    onSuccess?()
                }
            }
        }
        .hButtonIsLoading(vm.isLoading)
    }

    private var placeholder: String {
        if let bankName = vm.bankName {
            return L10n.paymentsAccount + " - " + bankName
        }
        return L10n.paymentsAccount
    }
}

@MainActor
@Observable
class NordeaPayoutSetupViewModel {
    var accountNumber: String = ""
    var bankName: String?
    var focusedField: NordeaPayoutField?
    var clearingError: String?
    var accountError: String?
    var isLoading: Bool = false
    var errorMessage: String?

    private let paymentService = hPaymentService()
    private let accountMasking = Masking(type: .bankAccountNumber)
    @ObservationIgnored private var accountNumberWatcher: ObservationWatcher?

    init() {
        accountNumberWatcher = ObservationWatcher { [weak self] in
            _ = self?.accountNumber
        } onChange: { [weak self] in
            guard let self else { return }
            withAnimation {
                self.bankName = self.accountNumber.bankName
            }
        }
    }

    func save() async -> Bool {
        withAnimation {
            clearingError = nil
            accountError = nil
            errorMessage = nil
        }

        if !validate() { return false }

        withAnimation { isLoading = true }
        defer { withAnimation { isLoading = false } }

        do {
            let result = try await paymentService.setupPaymentMethod(
                .nordeaPayout(
                    accountNumber: accountMasking.unmaskedValue(text: accountNumber)
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
        var newAccountError: String?

        if !accountMasking.isValid(text: accountMasking.unmaskedValue(text: accountNumber)) {
            newAccountError = L10n.claimChatFormTextMinChar(10)
        }

        guard newAccountError == nil else {
            withAnimation {
                accountError = newAccountError
                focusedField = .account
            }
            return false
        }
        return true
    }
}

enum NordeaPayoutField: hTextFieldFocusStateCompliant {
    case clearing
    case account

    static var last: NordeaPayoutField { .account }

    var next: NordeaPayoutField? {
        switch self {
        case .clearing: return .account
        case .account: return nil
        }
    }
}

#Preview {
    NordeaPayoutSetupScreen()
        .environmentObject(NavigationRouter())
}
