// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct QuoteFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment QuoteFragment on MoveIntent { __typename mtaQuotes { __typename startDate exposureName productVariant { __typename ...ProductVariantFragment } displayItems { __typename ...MoveQuoteDisplayItemFragment } addons { __typename ...MoveAddonQuoteFragment } totalCost { __typename ...ItemCostFragment } premium { __typename ...MoneyFragment } } homeQuotes { __typename deductible { __typename amount { __typename ...MoneyFragment } displayText percentage } defaultChoice displayItems { __typename ...MoveQuoteDisplayItemFragment } exposureName id productVariant { __typename ...ProductVariantFragment } startDate tierLevel tierName addons { __typename ...MoveAddonQuoteFragment } totalCost { __typename ...ItemCostFragment } premium { __typename ...MoneyFragment } } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntent }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("mtaQuotes", [MtaQuote].self),
      .field("homeQuotes", [HomeQuote].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      QuoteFragment.self
    ] }

    /// Will only be present after moveIntentRequest and for new V2_TIERS_AND_DEDUCTIBLES API.
    /// The MTA quotes for member's non-home contracts with new address.
    public var mtaQuotes: [MtaQuote] { __data["mtaQuotes"] }
    /// Will only be present after moveIntentRequest and for new V2_TIERS_AND_DEDUCTIBLES API.
    /// Quote variants for new home contract that member needs to pick one from.
    public var homeQuotes: [HomeQuote] { __data["homeQuotes"] }

    /// MtaQuote
    ///
    /// Parent Type: `MoveMtaQuote`
    nonisolated public struct MtaQuote: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveMtaQuote }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("startDate", OctopusGraphQL.Date.self),
        .field("exposureName", String.self),
        .field("productVariant", ProductVariant.self),
        .field("displayItems", [DisplayItem].self),
        .field("addons", [Addon].self),
        .field("totalCost", TotalCost.self),
        .field("premium", Premium.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        QuoteFragment.MtaQuote.self
      ] }

      ///  When new insurance (or existing insurance address change) is becoming active 
      public var startDate: OctopusGraphQL.Date { __data["startDate"] }
      ///  The insurance exposure name, eg reg nbr for car, name and birthdate for cat/dog, street for home etc... 
      public var exposureName: String { __data["exposureName"] }
      ///  The terms 
      public var productVariant: ProductVariant { __data["productVariant"] }
      ///  List of display items for the quote 
      public var displayItems: [DisplayItem] { __data["displayItems"] }
      ///  The addons moved to new address for agreement 
      public var addons: [Addon] { __data["addons"] }
      ///  Cost breakdown. Addons included 
      public var totalCost: TotalCost { __data["totalCost"] }
      ///  Premium 
      public var premium: Premium { __data["premium"] }

      /// MtaQuote.ProductVariant
      ///
      /// Parent Type: `ProductVariant`
      nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProductVariantFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.MtaQuote.ProductVariant.self,
          ProductVariantFragment.self
        ] }

        public var perils: [Peril] { __data["perils"] }
        public var typeOfContract: String { __data["typeOfContract"] }
        /// A `ProductVariant` is identified by its terms version, which is the more technical
        /// name for a unique incarnation of our insurances (products) at a point in time.
        public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
        public var documents: [Document] { __data["documents"] }
        public var displayName: String { __data["displayName"] }
        public var displayNameTier: String? { __data["displayNameTier"] }
        public var tierDescription: String? { __data["tierDescription"] }
        public var insurableLimits: [InsurableLimit] { __data["insurableLimits"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var productVariantFragment: ProductVariantFragment { _toFragment() }
        }

        public typealias Peril = ProductVariantFragment.Peril

        public typealias Document = ProductVariantFragment.Document

        public typealias InsurableLimit = ProductVariantFragment.InsurableLimit
      }

      /// MtaQuote.DisplayItem
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
          QuoteFragment.MtaQuote.DisplayItem.self,
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

      /// MtaQuote.Addon
      ///
      /// Parent Type: `MoveAddonQuote`
      nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveAddonQuote }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoveAddonQuoteFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.MtaQuote.Addon.self,
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

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var moveAddonQuoteFragment: MoveAddonQuoteFragment { _toFragment() }
        }

        public typealias DisplayItem = MoveAddonQuoteFragment.DisplayItem

        public typealias AddonVariant = MoveAddonQuoteFragment.AddonVariant

        public typealias Premium = MoveAddonQuoteFragment.Premium
      }

      /// MtaQuote.TotalCost
      ///
      /// Parent Type: `ItemCost`
      nonisolated public struct TotalCost: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ItemCostFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.MtaQuote.TotalCost.self,
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

      /// MtaQuote.Premium
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
          QuoteFragment.MtaQuote.Premium.self,
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

    /// HomeQuote
    ///
    /// Parent Type: `MoveHomeQuote`
    nonisolated public struct HomeQuote: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveHomeQuote }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("deductible", Deductible?.self),
        .field("defaultChoice", Bool.self),
        .field("displayItems", [DisplayItem].self),
        .field("exposureName", String.self),
        .field("id", OctopusGraphQL.ID.self),
        .field("productVariant", ProductVariant.self),
        .field("startDate", OctopusGraphQL.Date.self),
        .field("tierLevel", Int.self),
        .field("tierName", String.self),
        .field("addons", [Addon].self),
        .field("totalCost", TotalCost.self),
        .field("premium", Premium.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        QuoteFragment.HomeQuote.self
      ] }

      ///  The deductible if any 
      public var deductible: Deductible? { __data["deductible"] }
      ///  Flag to indicate if this is the default choice. Only one quote can be default 
      public var defaultChoice: Bool { __data["defaultChoice"] }
      ///  List of display items for the quote 
      public var displayItems: [DisplayItem] { __data["displayItems"] }
      ///  The insurance exposure name, eg reg nbr for car, name and birthdate for cat/dog, street for home etc... 
      public var exposureName: String { __data["exposureName"] }
      ///  The quote id, used to commit the selected quote 
      public var id: OctopusGraphQL.ID { __data["id"] }
      ///  The terms 
      public var productVariant: ProductVariant { __data["productVariant"] }
      ///  When new insurance (or existing insurance address change) is becoming active 
      public var startDate: OctopusGraphQL.Date { __data["startDate"] }
      ///  The tier level, a smaller number means lower coverage 
      public var tierLevel: Int { __data["tierLevel"] }
      ///  The tier name, eg BASIC, STANDARD, MAX 
      public var tierName: String { __data["tierName"] }
      ///  The addons moved from old home to new home 
      public var addons: [Addon] { __data["addons"] }
      ///  Cost breakdown. Addons included 
      public var totalCost: TotalCost { __data["totalCost"] }
      ///  Premium 
      public var premium: Premium { __data["premium"] }

      /// HomeQuote.Deductible
      ///
      /// Parent Type: `Deductible`
      nonisolated public struct Deductible: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Deductible }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("amount", Amount.self),
          .field("displayText", String.self),
          .field("percentage", Int.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.HomeQuote.Deductible.self
        ] }

        ///  The fixed deductible amount if any 
        public var amount: Amount { __data["amount"] }
        ///  The deductible display sub title 
        public var displayText: String { __data["displayText"] }
        ///  The deductible percentage if any 
        public var percentage: Int { __data["percentage"] }

        /// HomeQuote.Deductible.Amount
        ///
        /// Parent Type: `Money`
        nonisolated public struct Amount: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MoneyFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            QuoteFragment.HomeQuote.Deductible.Amount.self,
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

      /// HomeQuote.DisplayItem
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
          QuoteFragment.HomeQuote.DisplayItem.self,
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

      /// HomeQuote.ProductVariant
      ///
      /// Parent Type: `ProductVariant`
      nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProductVariantFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.HomeQuote.ProductVariant.self,
          ProductVariantFragment.self
        ] }

        public var perils: [Peril] { __data["perils"] }
        public var typeOfContract: String { __data["typeOfContract"] }
        /// A `ProductVariant` is identified by its terms version, which is the more technical
        /// name for a unique incarnation of our insurances (products) at a point in time.
        public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
        public var documents: [Document] { __data["documents"] }
        public var displayName: String { __data["displayName"] }
        public var displayNameTier: String? { __data["displayNameTier"] }
        public var tierDescription: String? { __data["tierDescription"] }
        public var insurableLimits: [InsurableLimit] { __data["insurableLimits"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var productVariantFragment: ProductVariantFragment { _toFragment() }
        }

        public typealias Peril = ProductVariantFragment.Peril

        public typealias Document = ProductVariantFragment.Document

        public typealias InsurableLimit = ProductVariantFragment.InsurableLimit
      }

      /// HomeQuote.Addon
      ///
      /// Parent Type: `MoveAddonQuote`
      nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveAddonQuote }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoveAddonQuoteFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.HomeQuote.Addon.self,
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

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var moveAddonQuoteFragment: MoveAddonQuoteFragment { _toFragment() }
        }

        public typealias DisplayItem = MoveAddonQuoteFragment.DisplayItem

        public typealias AddonVariant = MoveAddonQuoteFragment.AddonVariant

        public typealias Premium = MoveAddonQuoteFragment.Premium
      }

      /// HomeQuote.TotalCost
      ///
      /// Parent Type: `ItemCost`
      nonisolated public struct TotalCost: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ItemCostFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          QuoteFragment.HomeQuote.TotalCost.self,
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

      /// HomeQuote.Premium
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
          QuoteFragment.HomeQuote.Premium.self,
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

}