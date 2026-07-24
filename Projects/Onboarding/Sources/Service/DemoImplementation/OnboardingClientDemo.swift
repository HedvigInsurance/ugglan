import Foundation
import hCore

@MainActor
public class OnboardingClientDemo: OnboardingClient {
    public init() {}

    public func getOnboardingSteps() async throws -> [OnboardingStep] {
        await delay(1)
        return OnboardingClientDemo.getSteps()
    }

    public func updateContactInfo(email: String, phone: String) async throws {}

    static func getSteps() -> [OnboardingStep] {
        OnboardingStepList.compute(
            contracts: [
                .init(
                    id: "id1",
                    currentAgreement: nil,
                    exposureDisplayName: "exposure 1",
                    exposureDisplayNameShort: "exsposure 1 short",
                    masterInceptionDate: nil,
                    terminationDate: nil,
                    supportsAddressChange: true,
                    supportsCoInsured: true,
                    supportsCoOwners: true,
                    supportsTravelCertificate: true,
                    supportsChangeTier: true,
                    supportsTermination: true,
                    upcomingChangedAgreement: nil,
                    upcomingRenewal: nil,
                    firstName: "first name",
                    lastName: "last name",
                    ssn: "ssn",
                    typeOfContract: .seHouse,
                    coInsured: [.init(needsMissingInfo: true)],
                    coOwners: [.init(needsMissingInfo: true)],
                    missingPetChipId: true
                )
            ],
            contactInfo: .init(email: "demo@hedvig.com", phone: "0735328847")
        )
    }
}
