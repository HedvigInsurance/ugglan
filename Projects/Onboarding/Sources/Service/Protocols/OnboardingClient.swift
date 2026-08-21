import CrossSell
import Foundation

@MainActor
public protocol OnboardingClient {
    func getOnboardingSteps() async throws -> [OnboardingStep]
    func updateContactInfo(phone: String) async throws
    func getCrossSells() async throws -> [CrossSell]
    func getIsPaymentConnected() async throws -> Bool
}
