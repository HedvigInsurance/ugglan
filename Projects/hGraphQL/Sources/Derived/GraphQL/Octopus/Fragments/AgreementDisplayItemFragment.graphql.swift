// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AgreementDisplayItemFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment AgreementDisplayItemFragment on AgreementDisplayItem { __typename displayTitle displayValue displaySubtitle }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AgreementDisplayItem }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("displayTitle", String.self),
      .field("displayValue", String.self),
      .field("displaySubtitle", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AgreementDisplayItemFragment.self
    ] }

    public var displayTitle: String { __data["displayTitle"] }
    public var displayValue: String { __data["displayValue"] }
    public var displaySubtitle: String? { __data["displaySubtitle"] }
  }

}