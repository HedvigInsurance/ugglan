// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeTierDeductibleFromAgreementFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ChangeTierDeductibleFromAgreementFragment on ChangeTierDeductibleFromAgreement { __typename basePremium { __typename ...MoneyFragment } deductible { __typename amount { __typename ...MoneyFragment } percentage displayText } tierName tierLevel tierDescription displayItems { __typename displayTitle displaySubtitle displayValue } productVariant { __typename ...ProductVariantFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleFromAgreement }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("basePremium", BasePremium.self),
      .field("deductible", Deductible?.self),
      .field("tierName", String?.self),
      .field("tierLevel", Int?.self),
      .field("tierDescription", String?.self),
      .field("displayItems", [DisplayItem].self),
      .field("productVariant", ProductVariant.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ChangeTierDeductibleFromAgreementFragment.self
    ] }

    ///  Base Premium 
    public var basePremium: BasePremium { __data["basePremium"] }
    ///  The deductible if any 
    public var deductible: Deductible? { __data["deductible"] }
    ///  The tier name 
    public var tierName: String? { __data["tierName"] }
    ///  The tier level 
    public var tierLevel: Int? { __data["tierLevel"] }
    /// Optional tier description, if set use that rather than productVariant->tierDescription.
    /// An empty string means the description should deliberately be left blank.
    public var tierDescription: String? { __data["tierDescription"] }
    ///  List of display items for the quote 
    public var displayItems: [DisplayItem] { __data["displayItems"] }
    ///  The terms 
    public var productVariant: ProductVariant { __data["productVariant"] }

    /// BasePremium
    ///
    /// Parent Type: `Money`
    nonisolated public struct BasePremium: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeTierDeductibleFromAgreementFragment.BasePremium.self,
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

    /// Deductible
    ///
    /// Parent Type: `Deductible`
    nonisolated public struct Deductible: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Deductible }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("amount", Amount.self),
        .field("percentage", Int.self),
        .field("displayText", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeTierDeductibleFromAgreementFragment.Deductible.self
      ] }

      ///  The fixed deductible amount if any 
      public var amount: Amount { __data["amount"] }
      ///  The deductible percentage if any 
      public var percentage: Int { __data["percentage"] }
      ///  The deductible display sub title 
      public var displayText: String { __data["displayText"] }

      /// Deductible.Amount
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
          ChangeTierDeductibleFromAgreementFragment.Deductible.Amount.self,
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

    /// DisplayItem
    ///
    /// Parent Type: `ChangeTierDeductibleDisplayItem`
    nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleDisplayItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayTitle", String.self),
        .field("displaySubtitle", String?.self),
        .field("displayValue", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeTierDeductibleFromAgreementFragment.DisplayItem.self
      ] }

      public var displayTitle: String { __data["displayTitle"] }
      public var displaySubtitle: String? { __data["displaySubtitle"] }
      public var displayValue: String { __data["displayValue"] }
    }

    /// ProductVariant
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
        ChangeTierDeductibleFromAgreementFragment.ProductVariant.self,
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
  }

}