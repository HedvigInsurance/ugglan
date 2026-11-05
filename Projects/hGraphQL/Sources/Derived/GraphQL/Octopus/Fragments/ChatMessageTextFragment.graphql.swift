// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChatMessageTextFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ChatMessageTextFragment on ChatMessageText { __typename text actions { __typename title url } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageText }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("text", String.self),
      .field("actions", Actions?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ChatMessageTextFragment.self
    ] }

    public var text: String { __data["text"] }
    public var actions: Actions? { __data["actions"] }

    /// Actions
    ///
    /// Parent Type: `ChatMessageTextAction`
    nonisolated public struct Actions: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageTextAction }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("url", OctopusGraphQL.Url.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChatMessageTextFragment.Actions.self
      ] }

      public var title: String { __data["title"] }
      public var url: OctopusGraphQL.Url { __data["url"] }
    }
  }

}