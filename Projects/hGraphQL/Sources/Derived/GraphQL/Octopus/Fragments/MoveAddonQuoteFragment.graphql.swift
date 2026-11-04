// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveAddonQuoteFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MoveAddonQuoteFragment on MoveAddonQuote { __typename addonId displayName coverageDisplayName displayItems { __typename ...MoveQuoteDisplayItemFragment } startDate addonVariant { __typename ...AddonVariantFragment } premium { __typename ...MoneyFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveAddonQuote }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("addonId", OctopusGraphQL.ID.self),
      .field("displayName", String.self),
      .field("coverageDisplayName", String.self),
      .field("displayItems", [DisplayItem].self),
      .field("startDate", OctopusGraphQL.Date.self),
      .field("addonVariant", AddonVariant.self),
      .field("premium", Premium.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MoveAddonQuoteFragment.self
    ] }

    ///  The addon id 
    public var addonId: OctopusGraphQL.ID { __data["addonId"] }
    ///  Display name for the addon. 
    public var displayName: String { __data["displayName"] }
    /// The display name of the "coverage" of this addon
    /// This could be the duration of the coverage etc
    public var coverageDisplayName: String { __data["coverageDisplayName"] }
    ///  The addon details 
    public var displayItems: [DisplayItem] { __data["displayItems"] }
    ///  When this addon is becoming active 
    public var startDate: OctopusGraphQL.Date { __data["startDate"] }
    ///  The terms 
    public var addonVariant: AddonVariant { __data["addonVariant"] }
    ///  Premium 
    public var premium: Premium { __data["premium"] }

    /// DisplayItem
    ///
    /// Parent Type: `MoveQuoteDisplayItem`
    nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveQuoteDisplayItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoveQuoteDisplayItemFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveAddonQuoteFragment.DisplayItem.self,
        MoveQuoteDisplayItemFragment.self
      ] }

      public var displayTitle: String { __data["displayTitle"] }
      public var displaySubtitle: String? { __data["displaySubtitle"] }
      public var displayValue: String { __data["displayValue"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var moveQuoteDisplayItemFragment: MoveQuoteDisplayItemFragment { _toFragment() }
      }
    }

    /// AddonVariant
    ///
    /// Parent Type: `AddonVariant`
    nonisolated public struct AddonVariant: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonVariant }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(AddonVariantFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveAddonQuoteFragment.AddonVariant.self,
        AddonVariantFragment.self
      ] }

      /// A `AddonVariant` is identified by its terms version, which is the more technical
      /// name for a unique incarnation of our addons at a point in time.
      public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
      public var product: String { __data["product"] }
      public var addonPerils: [AddonPeril] { __data["addonPerils"] }
      public var documents: [Document] { __data["documents"] }
      public var displayName: String { __data["displayName"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var addonVariantFragment: AddonVariantFragment { _toFragment() }
      }

      public typealias AddonPeril = AddonVariantFragment.AddonPeril

      public typealias Document = AddonVariantFragment.Document
    }

    /// Premium
    ///
    /// Parent Type: `Money`
    nonisolated public struct Premium: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveAddonQuoteFragment.Premium.self,
        MoneyFragment.self
      ] }

      public var amount: Double { __data["amount"] }
      /// Currency of the money (ISO 4217).
      public var currencyCode: GraphQLEnum<OctopusGraphQL.CurrencyCode> { __data["currencyCode"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var moneyFragment: MoneyFragment { _toFragment() }
      }
    }
  }

}