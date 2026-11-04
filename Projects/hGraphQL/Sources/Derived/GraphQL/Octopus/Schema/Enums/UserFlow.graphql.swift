// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated enum UserFlow: String, EnumType {
    /// Insurances screen - all cross-sells led by the recommendation, no separate recommendation
    case insurances = "INSURANCES"
    /// Home screen - recommendation + other cross-sells
    case homeXSell = "HOME_X_SELL"
    /// Smart cross-sell - focused recommendation OR the full list, never both
    case smartXSell = "SMART_X_SELL"
    /// End of onboarding - all cross-sells led by the recommendation
    case onboarding = "ONBOARDING"
    /// Home screen - all cross-sells led by the recommendation
    case home = "HOME"
    /// Chat - a single generic recommendation linking to all insurances, no other cross-sells.
    /// Render it from recommendedCrossSell.crossSell (title, description, buttonTitle, storeUrl); the outer
    /// RecommendedCrossSell banner and button fields carry generic copy and should be ignored.
    case inChatXSell = "IN_CHAT_X_SELL"
  }

}