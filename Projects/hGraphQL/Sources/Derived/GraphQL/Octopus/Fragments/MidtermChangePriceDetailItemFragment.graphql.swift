// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MidtermChangePriceDetailItemFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MidtermChangePriceDetailItemFragment on MidtermChangePriceDetailItem { __typename displayName displayValue }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MidtermChangePriceDetailItem }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("displayName", String.self),
      .field("displayValue", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MidtermChangePriceDetailItemFragment.self
    ] }

    public var displayName: String { __data["displayName"] }
    public var displayValue: String { __data["displayValue"] }
  }

}