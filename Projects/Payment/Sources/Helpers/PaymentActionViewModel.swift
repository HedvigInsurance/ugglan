import SwiftUI
import hCore

@MainActor
class PaymentActionViewModel: ObservableObject {
    @Published var processingState: ProcessingState = .success
    let paymentService = hPaymentService()

    var isLoading: Bool {
        processingState == .loading
    }

    var errorMessage: String? {
        if case let .error(errorMessage) = processingState { return errorMessage }
        return nil
    }

    func perform(_ action: () async throws -> Void) async -> Bool {
        withAnimation { processingState = .loading }
        do {
            try await action()
            withAnimation { processingState = .success }
            return true
        } catch {
            withAnimation { processingState = .error(errorMessage: error.localizedDescription) }
            return false
        }
    }
}
