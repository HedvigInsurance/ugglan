// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct CrossSellQuery: GraphQLQuery {
    public static let operationName: String = "CrossSell"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CrossSell($input: CrossSellInput!) { currentMember { __typename crossSellV2(input: $input) { __typename otherCrossSells { __typename ...CrossSellFragment } recommendedAddon { __typename id title description buttonText deepLink bannerText benefits pillowImageLarge { __typename ...StoryblokImageAssetFragment } } recommendedCrossSell { __typename bannerText buttonText crossSell { __typename ...CrossSellFragment } discountText buttonDescription backgroundPillowImages { __typename leftImage { __typename ...StoryblokImageAssetFragment } rightImage { __typename ...StoryblokImageAssetFragment } } numberOfEligibleContracts discountPercent } } } }"#,
        fragments: [CrossSellFragment.self, StoryblokImageAssetFragment.self]
      ))

    public var input: CrossSellInput

    public init(input: CrossSellInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CrossSellQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("crossSellV2", CrossSellV2.self, arguments: ["input": .variable("input")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CrossSellQuery.Data.CurrentMember.self
        ] }

        /// Returns cross-sells with optional smart recommendation.
        ///
        /// - INSURANCES: All cross-sells in otherCrossSells led by the recommendation, no separate recommendation
        /// - HOME: Same response as INSURANCES; a distinct value so Home traffic is separable in attribution
        /// - ONBOARDING: Same response as INSURANCES; a distinct value for onboarding attribution
        /// - HOME_X_SELL: Recommendation returned separately, plus the remaining cross-sells
        /// - SMART_X_SELL (requires flowSource): Focused recommendation OR the full list, never both
        ///
        /// A listed cross-sell describes an available discount in its description for every flow except
        /// SMART_X_SELL. Where no discount applies it falls back to the plain product description.
        public var crossSellV2: CrossSellV2 { __data["crossSellV2"] }

        /// CurrentMember.CrossSellV2
        ///
        /// Parent Type: `CrossSellV2`
        nonisolated public struct CrossSellV2: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.CrossSellV2 }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("otherCrossSells", [OtherCrossSell].self),
            .field("recommendedAddon", RecommendedAddon?.self),
            .field("recommendedCrossSell", RecommendedCrossSell?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            CrossSellQuery.Data.CurrentMember.CrossSellV2.self
          ] }

          /// Other available cross-sells (behavior varies by userFlow)
          public var otherCrossSells: [OtherCrossSell] { __data["otherCrossSells"] }
          /// Addon recommendation for the contract in input.contractId (null when not applicable)
          public var recommendedAddon: RecommendedAddon? { __data["recommendedAddon"] }
          /// Prioritized recommendation (null for INSURANCES)
          public var recommendedCrossSell: RecommendedCrossSell? { __data["recommendedCrossSell"] }

          /// CurrentMember.CrossSellV2.OtherCrossSell
          ///
          /// Parent Type: `CrossSell`
          nonisolated public struct OtherCrossSell: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.CrossSell }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(CrossSellFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              CrossSellQuery.Data.CurrentMember.CrossSellV2.OtherCrossSell.self,
              CrossSellFragment.self
            ] }

            public var id: OctopusGraphQL.ID { __data["id"] }
            public var description: String { __data["description"] }
            /// Product page URL for completing the purchase
            public var storeUrl: String { __data["storeUrl"] }
            public var title: String { __data["title"] }
            public var buttonTitle: String { __data["buttonTitle"] }
            public var pillowImageSmall: PillowImageSmall { __data["pillowImageSmall"] }
            public var pillowImageLarge: PillowImageLarge { __data["pillowImageLarge"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var crossSellFragment: CrossSellFragment { _toFragment() }
            }

            public typealias PillowImageSmall = CrossSellFragment.PillowImageSmall

            public typealias PillowImageLarge = CrossSellFragment.PillowImageLarge
          }

          /// CurrentMember.CrossSellV2.RecommendedAddon
          ///
          /// Parent Type: `RecommendedAddonCrossSell`
          nonisolated public struct RecommendedAddon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.RecommendedAddonCrossSell }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", OctopusGraphQL.ID.self),
              .field("title", String.self),
              .field("description", String.self),
              .field("buttonText", String.self),
              .field("deepLink", String.self),
              .field("bannerText", String?.self),
              .field("benefits", [String].self),
              .field("pillowImageLarge", PillowImageLarge.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedAddon.self
            ] }

            public var id: OctopusGraphQL.ID { __data["id"] }
            public var title: String { __data["title"] }
            public var description: String { __data["description"] }
            public var buttonText: String { __data["buttonText"] }
            /// App deep link to the addon flow for this contract
            public var deepLink: String { __data["deepLink"] }
            /// Optional banner text shown above the card; clients fall back to a default when null
            public var bannerText: String? { __data["bannerText"] }
            /// Benefit rows shown as a checkmark list; empty when none
            public var benefits: [String] { __data["benefits"] }
            public var pillowImageLarge: PillowImageLarge { __data["pillowImageLarge"] }

            /// CurrentMember.CrossSellV2.RecommendedAddon.PillowImageLarge
            ///
            /// Parent Type: `StoryblokImageAsset`
            nonisolated public struct PillowImageLarge: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.StoryblokImageAsset }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(StoryblokImageAssetFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedAddon.PillowImageLarge.self,
                StoryblokImageAssetFragment.self
              ] }

              public var src: String { __data["src"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var storyblokImageAssetFragment: StoryblokImageAssetFragment { _toFragment() }
              }
            }
          }

          /// CurrentMember.CrossSellV2.RecommendedCrossSell
          ///
          /// Parent Type: `RecommendedCrossSell`
          nonisolated public struct RecommendedCrossSell: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.RecommendedCrossSell }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("bannerText", String.self),
              .field("buttonText", String.self),
              .field("crossSell", CrossSell.self),
              .field("discountText", String?.self),
              .field("buttonDescription", String.self),
              .field("backgroundPillowImages", BackgroundPillowImages?.self),
              .field("numberOfEligibleContracts", Int.self),
              .field("discountPercent", Int?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedCrossSell.self
            ] }

            public var bannerText: String { __data["bannerText"] }
            public var buttonText: String { __data["buttonText"] }
            public var crossSell: CrossSell { __data["crossSell"] }
            public var discountText: String? { __data["discountText"] }
            public var buttonDescription: String { __data["buttonDescription"] }
            public var backgroundPillowImages: BackgroundPillowImages? { __data["backgroundPillowImages"] }
            public var numberOfEligibleContracts: Int { __data["numberOfEligibleContracts"] }
            public var discountPercent: Int? { __data["discountPercent"] }

            /// CurrentMember.CrossSellV2.RecommendedCrossSell.CrossSell
            ///
            /// Parent Type: `CrossSell`
            nonisolated public struct CrossSell: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.CrossSell }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(CrossSellFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedCrossSell.CrossSell.self,
                CrossSellFragment.self
              ] }

              public var id: OctopusGraphQL.ID { __data["id"] }
              public var description: String { __data["description"] }
              /// Product page URL for completing the purchase
              public var storeUrl: String { __data["storeUrl"] }
              public var title: String { __data["title"] }
              public var buttonTitle: String { __data["buttonTitle"] }
              public var pillowImageSmall: PillowImageSmall { __data["pillowImageSmall"] }
              public var pillowImageLarge: PillowImageLarge { __data["pillowImageLarge"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var crossSellFragment: CrossSellFragment { _toFragment() }
              }

              public typealias PillowImageSmall = CrossSellFragment.PillowImageSmall

              public typealias PillowImageLarge = CrossSellFragment.PillowImageLarge
            }

            /// CurrentMember.CrossSellV2.RecommendedCrossSell.BackgroundPillowImages
            ///
            /// Parent Type: `RecommendedCrossSellBackgroundPillowImages`
            nonisolated public struct BackgroundPillowImages: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.RecommendedCrossSellBackgroundPillowImages }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("leftImage", LeftImage.self),
                .field("rightImage", RightImage.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedCrossSell.BackgroundPillowImages.self
              ] }

              public var leftImage: LeftImage { __data["leftImage"] }
              public var rightImage: RightImage { __data["rightImage"] }

              /// CurrentMember.CrossSellV2.RecommendedCrossSell.BackgroundPillowImages.LeftImage
              ///
              /// Parent Type: `StoryblokImageAsset`
              nonisolated public struct LeftImage: OctopusGraphQL.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.StoryblokImageAsset }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(StoryblokImageAssetFragment.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedCrossSell.BackgroundPillowImages.LeftImage.self,
                  StoryblokImageAssetFragment.self
                ] }

                public var src: String { __data["src"] }

                public struct Fragments: FragmentContainer {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  public var storyblokImageAssetFragment: StoryblokImageAssetFragment { _toFragment() }
                }
              }

              /// CurrentMember.CrossSellV2.RecommendedCrossSell.BackgroundPillowImages.RightImage
              ///
              /// Parent Type: `StoryblokImageAsset`
              nonisolated public struct RightImage: OctopusGraphQL.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.StoryblokImageAsset }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(StoryblokImageAssetFragment.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedCrossSell.BackgroundPillowImages.RightImage.self,
                  StoryblokImageAssetFragment.self
                ] }

                public var src: String { __data["src"] }

                public struct Fragments: FragmentContainer {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  public var storyblokImageAssetFragment: StoryblokImageAssetFragment { _toFragment() }
                }
              }
            }
          }
        }
      }
    }
  }

}