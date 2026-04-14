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
                hSection {
                    hFloatingTextField(
                        masking: .init(type: .digits),
                        value: $vm.clearingNumber,
                        equals: $vm.focusedField,
                        focusValue: .clearing,
                        placeholder: "Clearing",
                        error: $vm.clearingError
                    )
                }
                hSection {
                    hFloatingTextField(
                        masking: .init(type: .digits),
                        value: $vm.accountNumber,
                        equals: $vm.focusedField,
                        focusValue: .account,
                        placeholder: "Konto",
                        error: $vm.accountError
                    )
                }
            }
        }
        .hFormAttachToBottom {
            hSection {
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
            .padding(.vertical, .padding16)
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .navigationTitle("Bankkonto")
        .embededInNavigation(router: router, tracking: self)
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

    private let paymentService = hPaymentService()

    @discardableResult
    func save() async -> Bool {
        clearingError = nil
        accountError = nil

        guard !clearingNumber.isEmpty else {
            clearingError = "Missing clearing number"
            return false
        }
        guard !accountNumber.isEmpty else {
            accountError = "Missing account number"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await paymentService.setupPaymentMethod(
                .nordeaPayout(
                    setAsDefault: true,
                    clearingNumber: clearingNumber,
                    accountNumber: accountNumber
                )
            )
            if let errorMessage = result.errorMessage {
                clearingError = errorMessage
                return false
            }
            return true
        } catch {
            clearingError = error.localizedDescription
            return false
        }
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
