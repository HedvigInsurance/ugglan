// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractDiscountDetailsFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ContractDiscountDetailsFragment on ContractDiscountDetails { __typename discountsInfo discounts { __typename ...ContractDiscountDetailsItemFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractDiscountDetails }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("discountsInfo", String?.self),
      .field("discounts", [Discount].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ContractDiscountDetailsFragment.self
    ] }

    ///  A text to show if an extra explanation is needed, e.g. Your bundle discount will activate when you have two active insurances.
    public var discountsInfo: String? { __data["discountsInfo"] }
    ///  Contract level discounts.
    public var discounts: [Discount] { __data["discounts"] }

    /// Discount
    ///
    /// Parent Type: `ContractDiscountItem`
    nonisolated public struct Discount: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractDiscountItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ContractDiscountDetailsItemFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractDiscountDetailsFragment.Discount.self,
        ContractDiscountDetailsItemFragment.self
      ] }

      ///  Campaign code or some hardcoded descriptor of discount, ex. BUNDLE / FURRY / etc
      public var campaignCode: String { __data["campaignCode"] }
      ///  Longer explanation for the discount, ex. "50% discount for 6 months" or "15% bundle discount
      public var description: String { __data["description"] }
      ///  Status of the discount itself: active, terminated or pending (an active contract can have a pending bundle discount,
      /// for example).
      public var discountStatus: GraphQLEnum<OctopusGraphQL.ContractDiscountStatus> { __data["discountStatus"] }
      ///  Describes discount status with date if needed: Expired 31 aug 2025 or Active or Pending or Valid until 31 mars 2026
      public var statusDescription: String { __data["statusDescription"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var contractDiscountDetailsItemFragment: ContractDiscountDetailsItemFragment { _toFragment() }
      }
    }
  }

}