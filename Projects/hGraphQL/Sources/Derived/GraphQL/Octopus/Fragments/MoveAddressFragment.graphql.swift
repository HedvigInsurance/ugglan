// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveAddressFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MoveAddressFragment on MoveAddress { __typename id displaySubtitle displayTitle maxMovingDate minMovingDate suggestedNumberCoInsured }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveAddress }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("displaySubtitle", String?.self),
      .field("displayTitle", String.self),
      .field("maxMovingDate", OctopusGraphQL.Date.self),
      .field("minMovingDate", OctopusGraphQL.Date.self),
      .field("suggestedNumberCoInsured", Int.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MoveAddressFragment.self
    ] }

    ///  Address id, will correlate to the contract id 
    public var id: OctopusGraphQL.ID { __data["id"] }
    ///  Display subtitle for the contract when selecting moving flow 
    public var displaySubtitle: String? { __data["displaySubtitle"] }
    ///  Display title for the contract when selecting moving flow 
    public var displayTitle: String { __data["displayTitle"] }
    ///  The latest possible move date according to current contract 
    public var maxMovingDate: OctopusGraphQL.Date { __data["maxMovingDate"] }
    ///  The earliest possible move date according to current contract 
    public var minMovingDate: OctopusGraphQL.Date { __data["minMovingDate"] }
    ///  Number of co-insured from existing contract to use as default 
    public var suggestedNumberCoInsured: Int { __data["suggestedNumberCoInsured"] }
  }

}