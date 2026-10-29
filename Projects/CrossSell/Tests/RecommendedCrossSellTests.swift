import Foundation
import Testing

@testable import CrossSell

@MainActor
final class RecommendedCrossSellTests {
    private func makeInsurance(id: String = "insurance-id", bannerText: String? = nil) -> CrossSell {
        .init(
            id: id,
            title: "title",
            description: "description",
            buttonTitle: "button title",
            webActionURL: "",
            bannerText: bannerText,
            imageUrl: nil,
            buttonDescription: "button description"
        )
    }

    private func makeAddon(id: String = "addon-id", bannerText: String? = nil) -> AddonCrossSell {
        .init(
            id: id,
            title: "title",
            description: "description",
            buttonText: "button text",
            deepLink: "https://link.dev.hedvigit.com/travel-addon",
            bannerText: bannerText,
            imageUrl: nil
        )
    }

    @Test
    func insuranceForwardsIdAndBannerText() {
        let recommended: RecommendedCrossSell = .insurance(makeInsurance(id: "1", bannerText: "Save 15%"))

        #expect(recommended.id == "1")
        #expect(recommended.bannerText == "Save 15%")
    }

    @Test
    func addonForwardsIdAndBannerText() {
        let recommended: RecommendedCrossSell = .addon(
            makeAddon(id: "2", bannerText: "Add extra safety when traveling")
        )

        #expect(recommended.id == "2")
        #expect(recommended.bannerText == "Add extra safety when traveling")
    }

    @Test
    func addonWithoutBannerHasNoBannerText() {
        let recommended: RecommendedCrossSell = .addon(makeAddon(id: "3"))

        #expect(recommended.id == "3")
        #expect(recommended.bannerText == nil)
    }

    @Test
    func hasRecommendationTrueForInsurance() {
        let crossSells: CrossSells = .init(
            recommended: .insurance(makeInsurance()),
            others: []
        )

        #expect(crossSells.hasRecommendation)
    }

    @Test
    func hasRecommendationTrueForAddon() {
        let crossSells: CrossSells = .init(
            recommended: .addon(makeAddon()),
            others: []
        )

        #expect(crossSells.hasRecommendation)
    }

    @Test
    func hasRecommendationFalseWhenNil() {
        let crossSells: CrossSells = .init(
            recommended: nil,
            others: []
        )

        #expect(!crossSells.hasRecommendation)
    }
}
