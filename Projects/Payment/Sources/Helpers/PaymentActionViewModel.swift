import SwiftUI
import hCore

/// A one-shot mutation on one connected payment method: run it, expose loading and any error.
/// The operation is injected rather than subclassed, so the sheet driving it stays a single view.
@MainActor
class PaymentActionViewModel: ObservableObject {
    @Published var processingState: ProcessingState = .success
    let method: ConnectedPaymentMethod

    private let paymentService = hPaymentService()
    private let action: (ConnectedPaymentMethod, hPaymentService) async throws -> Void

    init(
        method: ConnectedPaymentMethod,
        action: @escaping (ConnectedPaymentMethod, hPaymentService) async throws -> Void
    ) {
        self.method = method
        self.action = action
    }

    var isLoading: Bool {
        processingState == .loading
    }

    var errorMessage: String? {
        if case let .error(errorMessage) = processingState { return errorMessage }
        return nil
    }

    func perform() async -> Bool {
        withAnimation { processingState = .loading }
        do {
            try await action(method, paymentService)
            withAnimation { processingState = .success }
            return true
        } catch {
            withAnimation { processingState = .error(errorMessage: error.localizedDescription) }
            return false
        }
    }
}

extension PaymentActionViewModel {
    /// Makes the method the member's primary pay-in method.
    static func setDefault(_ method: ConnectedPaymentMethod) -> PaymentActionViewModel {
        .init(method: method) { method, service in
            try await service.setDefaultPaymentMethod(method.method)
        }
    }

    /// Drops the method's provider from the member's pay-in methods.
    static func remove(_ method: ConnectedPaymentMethod) -> PaymentActionViewModel {
        .init(method: method) { method, service in
            try await service.removePaymentMethod(method.provider)
        }
    }
}
