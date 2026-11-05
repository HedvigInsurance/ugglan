// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractDiscountDetailsItemFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ContractDiscountDetailsItemFragment on ContractDiscountItem { __typename campaignCode description discountStatus statusDescription }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractDiscountItem }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("campaignCode", String.self),
      .field("description", String.self),
      .field("discountStatus", GraphQLEnum<OctopusGraphQL.ContractDiscountStatus>.self),
      .field("statusDescription", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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
  }

}