import TestDependencies
import Testing
import hCore
import hCoreUI

@testable import Forever

extension ForeverDependencySuite {
    @MainActor
    final class ForeverTests {
        private weak var sut: MockForeverService?

        @Test
        func fetchMemberReferralInformationSuccess() async {
            let memberReferralInformation: ForeverData = .init(
                grossAmount: .init(amount: "120", currency: "SEK"),
                netAmount: .init(amount: "110", currency: "SEK"),
                otherDiscounts: nil,
                discountCode: "discount code",
                monthlyDiscount: .init(amount: "10", currency: "SEK"),
                referrals: [],
                referredBy: nil,
                monthlyDiscountPerReferral: .init(amount: "10", currency: "SEK")
            )

            // Scoped so mockService is released before expectServiceReleased() runs.
            await recordingErrors {
                let mockService = MockData.createMockForeverService(
                    fetchMemberReferralInformation: { memberReferralInformation }
                )
                sut = mockService

                let respondedInformation = try await mockService.getMemberReferralInformation()
                #expect(respondedInformation == memberReferralInformation)
            }

            await expectServiceReleased()
        }

        @Test
        func codeChangeSuccess() async {
            let code = "new code"

            let model = TextInputViewModel(
                masking: .init(type: .none),
                input: code,
                title: L10n.ReferralsEmpty.Code.headline
            )

            await model.save()
            #expect(model.input == code)
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: ForeverClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }
    }
}
