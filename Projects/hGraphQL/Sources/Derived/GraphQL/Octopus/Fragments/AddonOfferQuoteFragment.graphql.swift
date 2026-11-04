// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonOfferQuoteFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment AddonOfferQuoteFragment on AddonOfferQuote { __typename id displayTitle displayDescription subtype displayItems { __typename displayTitle displayValue } cost { __typename ...ItemCostFragment } addonVariant { __typename ...AddonVariantFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOfferQuote }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("displayTitle", String.self),
      .field("displayDescription", String.self),
      .field("subtype", String?.self),
      .field("displayItems", [DisplayItem].self),
      .field("cost", Cost.self),
      .field("addonVariant", AddonVariant.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AddonOfferQuoteFragment.self
    ] }

    /// Id of the addon.
    public var id: OctopusGraphQL.ID { __data["id"] }
    /// Display value of the addon. Will be shown in the select days dropdown. eg 45 days 60 days
    public var displayTitle: String { __data["displayTitle"] }
    /// Display description we want to show that explains addon
    public var displayDescription: String { __data["displayDescription"] }
    ///  Addon subtype 
    public var subtype: String? { __data["subtype"] }
    /// Display items of the addon.
    /// eg 'Coverage' with a value of '45 days'
    public var displayItems: [DisplayItem] { __data["displayItems"] }
    /// Cost of the addon
    public var cost: Cost { __data["cost"] }
    /// Addon variant
    public var addonVariant: AddonVariant { __data["addonVariant"] }

    /// DisplayItem
    ///
    /// Parent Type: `AddonDisplayItem`
    nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonDisplayItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayTitle", String.self),
        .field("displayValue", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonOfferQuoteFragment.DisplayItem.self
      ] }

      public var displayTitle: String { __data["displayTitle"] }
      public var displayValue: String { __data["displayValue"] }
    }

    /// Cost
    ///
    /// Parent Type: `ItemCost`
    nonisolated public struct Cost: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ItemCostFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonOfferQuoteFragment.Cost.self,
        ItemCostFragment.self
      ] }

      public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
      public var monthlyNet: MonthlyNet { __data["monthlyNet"] }
      public var discounts: [Discount] { __data["discounts"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var itemCostFragment: ItemCostFragment { _toFragment() }
      }

      public typealias MonthlyGross = ItemCostFragment.MonthlyGross

      public typealias MonthlyNet = ItemCostFragment.MonthlyNet

      public typealias Discount = ItemCostFragment.Discount
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
        AddonOfferQuoteFragment.AddonVariant.self,
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
  }

}