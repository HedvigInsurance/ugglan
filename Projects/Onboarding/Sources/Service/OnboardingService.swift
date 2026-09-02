import AutomaticLog
import CrossSell
import Foundation
import hCore

@MainActor
public class OnboardingService {
    @Inject var client: OnboardingClient

    public init() {}

    @Log
    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        try await client.getOnboardingSteps()
    }

    @Log(masked: ["phone"])
    public func updateContactInfo(phone: String) async throws {
        try await client.updateContactInfo(phone: phone)
    }

    @Log
    public func getCrossSells() async throws -> [CrossSell] {
        try await client.getCrossSells()
    }

    @Log
    public func getIsPaymentConnected() async throws -> Bool {
        try await client.getIsPaymentConnected()
    }
}
