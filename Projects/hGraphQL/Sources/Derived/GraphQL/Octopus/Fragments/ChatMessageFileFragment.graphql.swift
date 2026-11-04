// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChatMessageFileFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ChatMessageFileFragment on ChatMessageFile { __typename signedUrl mimeType fileName }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageFile }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("signedUrl", OctopusGraphQL.Url.self),
      .field("mimeType", String.self),
      .field("fileName", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ChatMessageFileFragment.self
    ] }

    public var signedUrl: OctopusGraphQL.Url { __data["signedUrl"] }
    public var mimeType: String { __data["mimeType"] }
    public var fileName: String? { __data["fileName"] }
  }

}