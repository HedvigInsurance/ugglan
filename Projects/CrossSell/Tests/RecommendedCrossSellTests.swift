import Foundation
import XCTest

@testable import CrossSell

@MainActor
final class RecommendedCrossSellTests: XCTestCase {
    private func makeInsurance(id: String = "insurance-id", bannerText: String? = nil) -> CrossSell {
        .init(
            id: id,
            title: "title",
            description: "description",
            buttonTitle: "button title",
            bannerText: bannerText,
            imageUrl: nil,
            buttonDescription: "button description"
        )
    }

    private func makeAddon(id: String = "addon-id") -> AddonCrossSell {
        .init(
            id: id,
            title: "title",
            description: "description",
            buttonText: "button text",
            deepLink: "https://link.dev.hedvigit.com/travel-addon",
            imageUrl: nil
        )
    }

    func testInsuranceForwardsIdAndBannerText() {
        let recommended: RecommendedCrossSell = .insurance(makeInsurance(id: "1", bannerText: "Save 15%"))

        assert(recommended.id == "1")
        assert(recommended.bannerText == "Save 15%")
    }

    func testAddonForwardsIdAndHasNoBannerText() {
        let recommended: RecommendedCrossSell = .addon(makeAddon(id: "2"))

        assert(recommended.id == "2")
        assert(recommended.bannerText == nil)
    }

    func testHasRecommendationTrueForInsurance() {
        let crossSells: CrossSells = .init(
            recommended: .insurance(makeInsurance()),
            others: [],
            discountAvailable: false
        )

        assert(crossSells.hasRecommendation)
    }

    func testHasRecommendationTrueForAddon() {
        let crossSells: CrossSells = .init(
            recommended: .addon(makeAddon()),
            others: [],
            discountAvailable: false
        )

        assert(crossSells.hasRecommendation)
    }

    func testHasRecommendationFalseWhenNil() {
        let crossSells: CrossSells = .init(
            recommended: nil,
            others: [],
            discountAvailable: false
        )

        assert(!crossSells.hasRecommendation)
    }
}
