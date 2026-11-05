// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ItemDiscountFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ItemDiscountFragment on ItemDiscount { __typename displayName displayValue explanation campaignCode }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemDiscount }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("displayName", String.self),
      .field("displayValue", String.self),
      .field("explanation", String.self),
      .field("campaignCode", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ItemDiscountFragment.self
    ] }

    ///  Short name for list display, ex. "50% puppy discount" 
    public var displayName: String { __data["displayName"] }
    ///  Short value for list display, ex. 50% 99 kr 
    public var displayValue: String { __data["displayValue"] }
    ///  Longer explanation, ex. 50% discount for 6 months 
    public var explanation: String { __data["explanation"] }
    ///  Campaign code or some hardcoded descriptor of discount, ex. BUNDLE / BUYHEDVIG / etc 
    public var campaignCode: String { __data["campaignCode"] }
  }

}