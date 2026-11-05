// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MessagePageFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MessagePageFragment on ChatMessagePage { __typename messages { __typename ...MessageFragment } newerToken olderToken }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessagePage }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("messages", [Message].self),
      .field("newerToken", String?.self),
      .field("olderToken", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MessagePageFragment.self
    ] }

    public var messages: [Message] { __data["messages"] }
    public var newerToken: String? { __data["newerToken"] }
    public var olderToken: String? { __data["olderToken"] }

    /// Message
    ///
    /// Parent Type: `ChatMessage`
    nonisolated public struct Message: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Interfaces.ChatMessage }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MessageFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MessagePageFragment.Message.self,
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

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var messageFragment: MessageFragment { _toFragment() }
      }

      public typealias Disclaimer = MessageFragment.Disclaimer

      /// Message.AsChatMessageFile
      ///
      /// Parent Type: `ChatMessageFile`
      nonisolated public struct AsChatMessageFile: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = MessagePageFragment.Message
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageFile }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          MessagePageFragment.Message.self,
          MessageFragment.self,
          MessageFragment.AsChatMessageFile.self,
          ChatMessageFileFragment.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MessagePageFragment.Message.self,
          MessagePageFragment.Message.AsChatMessageFile.self,
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

          public var messageFragment: MessageFragment { _toFragment() }
          public var chatMessageFileFragment: ChatMessageFileFragment { _toFragment() }
        }

        public typealias Disclaimer = MessageFragment.Disclaimer
      }

      /// Message.AsChatMessageText
      ///
      /// Parent Type: `ChatMessageText`
      nonisolated public struct AsChatMessageText: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = MessagePageFragment.Message
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageText }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          MessagePageFragment.Message.self,
          MessageFragment.self,
          MessageFragment.AsChatMessageText.self,
          ChatMessageTextFragment.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MessagePageFragment.Message.self,
          MessagePageFragment.Message.AsChatMessageText.self,
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

          public var messageFragment: MessageFragment { _toFragment() }
          public var chatMessageTextFragment: ChatMessageTextFragment { _toFragment() }
        }

        public typealias Disclaimer = MessageFragment.Disclaimer

        public typealias Actions = ChatMessageTextFragment.Actions
      }
    }
  }

}