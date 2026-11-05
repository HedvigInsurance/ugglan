// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AgreementFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment AgreementFragment on Agreement { __typename id activeFrom activeTo certificateUrl creationCause basePremium { __typename ...MoneyFragment } productVariant { __typename ...ProductVariantFragment } addons { __typename addonVariant { __typename ...AddonVariantFragment } } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("activeFrom", OctopusGraphQL.Date.self),
      .field("activeTo", OctopusGraphQL.Date.self),
      .field("certificateUrl", OctopusGraphQL.Url?.self),
      .field("creationCause", GraphQLEnum<OctopusGraphQL.AgreementCreationCause>.self),
      .field("basePremium", BasePremium.self),
      .field("productVariant", ProductVariant.self),
      .field("addons", [Addon].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AgreementFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    /// The date this agreement took effect.
    public var activeFrom: OctopusGraphQL.Date { __data["activeFrom"] }
    /// The last date this is in effect.
    public var activeTo: OctopusGraphQL.Date { __data["activeTo"] }
    /// The URL of the insurance certificate.
    public var certificateUrl: OctopusGraphQL.Url? { __data["certificateUrl"] }
    /// The reason this agreement was created, useful to distinguish between renewals and other creations for instance.
    public var creationCause: GraphQLEnum<OctopusGraphQL.AgreementCreationCause> { __data["creationCause"] }
    /// The monthly premium of this agreement.
    public var basePremium: BasePremium { __data["basePremium"] }
    /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
    /// such as names, legal documents, perils etc.
    public var productVariant: ProductVariant { __data["productVariant"] }
    /// List of addons on the agreement.
    public var addons: [Addon] { __data["addons"] }

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
        AgreementFragment.BasePremium.self,
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
        AgreementFragment.ProductVariant.self,
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

    /// Addon
    ///
    /// Parent Type: `Addon`
    nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Addon }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("addonVariant", AddonVariant.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AgreementFragment.Addon.self
      ] }

      /// The AddonVariant of the agreement, which is the umbrella container for a lot of data related to the addon,
      /// such as names, legal documents, perils etc.
      public var addonVariant: AddonVariant { __data["addonVariant"] }

      /// Addon.AddonVariant
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
          AgreementFragment.Addon.AddonVariant.self,
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

}