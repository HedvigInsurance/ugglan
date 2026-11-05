// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoneyFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MoneyFragment on Money { __typename amount currencyCode }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("amount", Double.self),
      .field("currencyCode", GraphQLEnum<OctopusGraphQL.CurrencyCode>.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MoneyFragment.self
    ] }

    public var amount: Double { __data["amount"] }
    /// Currency of the money (ISO 4217).
    public var currencyCode: GraphQLEnum<OctopusGraphQL.CurrencyCode> { __data["currencyCode"] }
  }

}