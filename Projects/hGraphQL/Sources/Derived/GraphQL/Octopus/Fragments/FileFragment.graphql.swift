// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct FileFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment FileFragment on ClaimFile { __typename id name mimeType url }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFile }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("name", String.self),
      .field("mimeType", String.self),
      .field("url", OctopusGraphQL.Url.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      FileFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    /// The name of the file - usually what the person who uploaded named the file originally.
    public var name: String { __data["name"] }
    /// The mime/media type of the file. See: https://en.wikipedia.org/wiki/Media_type
    public var mimeType: String { __data["mimeType"] }
    /// The URL where the file can be read from.
    ///
    /// Note that these, for security reasons, are signed and somewhat short lived - which means that the the URL might
    /// become invalid for fetching. This can be fixed by simply re-loading the claim.
    public var url: OctopusGraphQL.Url { __data["url"] }
  }

}