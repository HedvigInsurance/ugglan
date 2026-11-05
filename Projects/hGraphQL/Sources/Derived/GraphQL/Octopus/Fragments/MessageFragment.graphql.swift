// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MessageFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MessageFragment on ChatMessage { __typename id sender sentAt disclaimer { __typename ...ChatMessageDisclaimerFragment } ...ChatMessageFileFragment ...ChatMessageTextFragment }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Interfaces.ChatMessage }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("sender", GraphQLEnum<OctopusGraphQL.ChatMessageSender>.self),
      .field("sentAt", OctopusGraphQL.Instant.self),
      .field("disclaimer", Disclaimer?.self),
      .inlineFragment(AsChatMessageFile.self),
      .inlineFragment(AsChatMessageText.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MessageFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var sender: GraphQLEnum<OctopusGraphQL.ChatMessageSender> { __data["sender"] }
    public var sentAt: OctopusGraphQL.Instant { __data["sentAt"] }
    /// An optional attachment to display with the message, which can provide
    /// additional relevant context to the message itself.
    public var disclaimer: Disclaimer? { __data["disclaimer"] }

    public var asChatMessageFile: AsChatMessageFile? { _asInlineFragment() }
    public var asChatMessageText: AsChatMessageText? { _asInlineFragment() }

    /// Disclaimer
    ///
    /// Parent Type: `ChatMessageDisclaimer`
    nonisolated public struct Disclaimer: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageDisclaimer }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ChatMessageDisclaimerFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MessageFragment.Disclaimer.self,
        ChatMessageDisclaimerFragment.self
      ] }

      public var description: String? { __data["description"] }
      /// The longer form of the description that's typically hidden behind a 'Read more' button.
      public var detailsDescription: String? { __data["detailsDescription"] }
      /// The title that goes with `detailsDescription`.
      public var detailsTitle: String? { __data["detailsTitle"] }
      public var title: String? { __data["title"] }
      public var type: GraphQLEnum<OctopusGraphQL.ChatMessageDisclaimerType> { __data["type"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var chatMessageDisclaimerFragment: ChatMessageDisclaimerFragment { _toFragment() }
      }
    }

    /// AsChatMessageFile
    ///
    /// Parent Type: `ChatMessageFile`
    nonisolated public struct AsChatMessageFile: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MessageFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageFile }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .fragment(ChatMessageFileFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MessageFragment.self,
        MessageFragment.AsChatMessageFile.self,
        ChatMessageFileFragment.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      public var sender: GraphQLEnum<OctopusGraphQL.ChatMessageSender> { __data["sender"] }
      public var sentAt: OctopusGraphQL.Instant { __data["sentAt"] }
      /// An optional attachment to display with the message, which can provide
      /// additional relevant context to the message itself.
      public var disclaimer: Disclaimer? { __data["disclaimer"] }
      public var signedUrl: OctopusGraphQL.Url { __data["signedUrl"] }
      public var mimeType: String { __data["mimeType"] }
      public var fileName: String? { __data["fileName"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var chatMessageFileFragment: ChatMessageFileFragment { _toFragment() }
      }

      public typealias Disclaimer = MessageFragment.Disclaimer
    }

    /// AsChatMessageText
    ///
    /// Parent Type: `ChatMessageText`
    nonisolated public struct AsChatMessageText: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MessageFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageText }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .fragment(ChatMessageTextFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MessageFragment.self,
        MessageFragment.AsChatMessageText.self,
        ChatMessageTextFragment.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      public var sender: GraphQLEnum<OctopusGraphQL.ChatMessageSender> { __data["sender"] }
      public var sentAt: OctopusGraphQL.Instant { __data["sentAt"] }
      /// An optional attachment to display with the message, which can provide
      /// additional relevant context to the message itself.
      public var disclaimer: Disclaimer? { __data["disclaimer"] }
      public var text: String { __data["text"] }
      public var actions: Actions? { __data["actions"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var chatMessageTextFragment: ChatMessageTextFragment { _toFragment() }
      }

      public typealias Disclaimer = MessageFragment.Disclaimer

      public typealias Actions = ChatMessageTextFragment.Actions
    }
  }

}