import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct NordeaPayoutSetupScreen: View {
    @StateObject private var vm = NordeaPayoutSetupViewModel()
    @StateObject var router = NavigationRouter()

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                clearingField
                accountField
            }
        }
        .hFormAttachToBottom {
            bottomContent
        }
        .disabled(vm.isLoading)
        .hFormContentPosition(.compact)
        .navigationTitle("Bankkonto")
        .embededInNavigation(router: router, tracking: self)
    }

    private var clearingField: some View {
        hSection {
            hFloatingTextField(
                masking: .init(type: .clearingNumber),
                value: $vm.clearingNumber,
                equals: $vm.focusedField,
                focusValue: .clearing,
                placeholder: "Clearing",
                error: $vm.clearingError
            )
        }
    }

    private var accountField: some View {
        hSection {
            hFloatingTextField(
                masking: .init(type: .bankAccountNumber),
                value: $vm.accountNumber,
                equals: $vm.focusedField,
                focusValue: .account,
                placeholder: "Konto",
                error: $vm.accountError
            )
        }
    }

    private var bottomContent: some View {
        hSection {
            if let errorMessage = vm.errorMessage {
                errorView(message: errorMessage)
            }
            saveButton
        }
        .padding(.vertical, .padding16)
        .sectionContainerStyle(.transparent)
    }

    private func errorView(message: String) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                .foregroundColor(hSignalColor.Red.element)
            hText(message, style: .label)
                .foregroundColor(hSignalColor.Red.text)
        }
        .padding(.bottom, .padding8)
    }

    private var saveButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalSaveButton),
            {
                Task {
                    let success = await vm.save()
                    if success {
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        store.send(.fetchPaymentStatus)
                        router.dismiss()
                    }
                }
            }
        )
        .hButtonIsLoading(vm.isLoading)
    }
}

extension NordeaPayoutSetupScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: NordeaPayoutSetupScreen.self)
    }
}

@MainActor
class NordeaPayoutSetupViewModel: ObservableObject {
    @Published var clearingNumber: String = ""
    @Published var accountNumber: String = ""
    @Published var focusedField: NordeaPayoutField?
    @Published var clearingError: String?
    @Published var accountError: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let paymentService = hPaymentService()
    private let clearingMasking = Masking(type: .clearingNumber)
    private let accountMasking = Masking(type: .bankAccountNumber)

    @discardableResult
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
                    setAsDefault: true,
                    clearingNumber: clearingNumber,
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
        var newClearingError: String?
        var newAccountError: String?

        if !clearingMasking.isValid(text: clearingNumber) {
            newClearingError = "Clearing number must be 4 or 5 digits"
        }
        if !accountMasking.isValid(text: accountMasking.unmaskedValue(text: accountNumber)) {
            newAccountError = "Account number must be at least 6 digits"
        }

        guard newClearingError == nil && newAccountError == nil else {
            withAnimation {
                clearingError = newClearingError
                accountError = newAccountError
                focusedField = newClearingError != nil ? .clearing : .account
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
