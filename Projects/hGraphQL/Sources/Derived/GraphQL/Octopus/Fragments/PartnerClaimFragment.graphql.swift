// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PartnerClaimFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PartnerClaimFragment on PartnerClaim { __typename id externalId exposureDisplayName status submittedAt payoutAmount { __typename ...MoneyFragment } associatedTypeOfContract claimType handlerEmail displayItems { __typename displayTitle displayValue } productVariant { __typename ...ProductVariantFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PartnerClaim }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("externalId", String.self),
      .field("exposureDisplayName", String?.self),
      .field("status", GraphQLEnum<OctopusGraphQL.ClaimStatus>?.self),
      .field("submittedAt", OctopusGraphQL.Date?.self),
      .field("payoutAmount", PayoutAmount?.self),
      .field("associatedTypeOfContract", String?.self),
      .field("claimType", String?.self),
      .field("handlerEmail", String?.self),
      .field("displayItems", [DisplayItem].self),
      .field("productVariant", ProductVariant?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PartnerClaimFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var externalId: String { __data["externalId"] }
    public var exposureDisplayName: String? { __data["exposureDisplayName"] }
    public var status: GraphQLEnum<OctopusGraphQL.ClaimStatus>? { __data["status"] }
    public var submittedAt: OctopusGraphQL.Date? { __data["submittedAt"] }
    public var payoutAmount: PayoutAmount? { __data["payoutAmount"] }
    public var associatedTypeOfContract: String? { __data["associatedTypeOfContract"] }
    public var claimType: String? { __data["claimType"] }
    public var handlerEmail: String? { __data["handlerEmail"] }
    public var displayItems: [DisplayItem] { __data["displayItems"] }
    /// Terms & conditions for the claim found using claims contractId and dateOfOccurrence, otherwise null.
    public var productVariant: ProductVariant? { __data["productVariant"] }

    /// PayoutAmount
    ///
    /// Parent Type: `Money`
    nonisolated public struct PayoutAmount: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PartnerClaimFragment.PayoutAmount.self,
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

    /// DisplayItem
    ///
    /// Parent Type: `ClaimDisplayItem`
    nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimDisplayItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayTitle", String.self),
        .field("displayValue", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PartnerClaimFragment.DisplayItem.self
      ] }

      public var displayTitle: String { __data["displayTitle"] }
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
        PartnerClaimFragment.ProductVariant.self,
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