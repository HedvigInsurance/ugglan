import SwiftUI
import hCore

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
    static func setDefault(_ method: ConnectedPaymentMethod) -> PaymentActionViewModel {
        .init(method: method) { method, service in
            try await service.setDefaultPaymentMethod(method.method)
        }
    }

    static func remove(_ method: ConnectedPaymentMethod) -> PaymentActionViewModel {
        .init(method: method) { method, service in
            try await service.removePaymentMethod(method.provider)
        }
    }
}
