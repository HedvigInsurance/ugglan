// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct CrossSellFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment CrossSellFragment on CrossSell { __typename id description storeUrl title buttonTitle pillowImageSmall { __typename ...StoryblokImageAssetFragment } pillowImageLarge { __typename ...StoryblokImageAssetFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.CrossSell }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("description", String.self),
      .field("storeUrl", String.self),
      .field("title", String.self),
      .field("buttonTitle", String.self),
      .field("pillowImageSmall", PillowImageSmall.self),
      .field("pillowImageLarge", PillowImageLarge.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// PillowImageSmall
    ///
    /// Parent Type: `StoryblokImageAsset`
    nonisolated public struct PillowImageSmall: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.StoryblokImageAsset }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(StoryblokImageAssetFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CrossSellFragment.PillowImageSmall.self,
        StoryblokImageAssetFragment.self
      ] }

      public var src: String { __data["src"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var storyblokImageAssetFragment: StoryblokImageAssetFragment { _toFragment() }
      }
    }

    /// PillowImageLarge
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
        CrossSellFragment.PillowImageLarge.self,
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