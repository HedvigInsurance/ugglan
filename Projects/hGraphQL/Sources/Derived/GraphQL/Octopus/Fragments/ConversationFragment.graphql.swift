// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ConversationFragment on Conversation { __typename createdAt id isOpen unreadMessageCount newestMessage { __typename ...MessageFragment } statusMessage isLegacy claim { __typename id claimType } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("createdAt", OctopusGraphQL.DateTime.self),
      .field("id", OctopusGraphQL.UUID.self),
      .field("isOpen", Bool.self),
      .field("unreadMessageCount", Int.self),
      .field("newestMessage", NewestMessage?.self),
      .field("statusMessage", String?.self),
      .field("isLegacy", Bool.self),
      .field("claim", Claim?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ConversationFragment.self
    ] }

    public var createdAt: OctopusGraphQL.DateTime { __data["createdAt"] }
    public var id: OctopusGraphQL.UUID { __data["id"] }
    public var isOpen: Bool { __data["isOpen"] }
    public var unreadMessageCount: Int { __data["unreadMessageCount"] }
    public var newestMessage: NewestMessage? { __data["newestMessage"] }
    public var statusMessage: String? { __data["statusMessage"] }
    public var isLegacy: Bool { __data["isLegacy"] }
    /// Return the claim for this conversation, if it has one.
    ///
    /// Conversations auto-created when a claim is opened will have this, others will not.
    /// The `legacyConversation` will not have any associated claim.
    public var claim: Claim? { __data["claim"] }

    /// NewestMessage
    ///
    /// Parent Type: `ChatMessage`
    nonisolated public struct NewestMessage: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Interfaces.ChatMessage }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MessageFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationFragment.NewestMessage.self,
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

      /// NewestMessage.AsChatMessageFile
      ///
      /// Parent Type: `ChatMessageFile`
      nonisolated public struct AsChatMessageFile: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ConversationFragment.NewestMessage
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageFile }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ConversationFragment.NewestMessage.self,
          MessageFragment.self,
          MessageFragment.AsChatMessageFile.self,
          ChatMessageFileFragment.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationFragment.NewestMessage.self,
          ConversationFragment.NewestMessage.AsChatMessageFile.self,
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

      /// NewestMessage.AsChatMessageText
      ///
      /// Parent Type: `ChatMessageText`
      nonisolated public struct AsChatMessageText: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ConversationFragment.NewestMessage
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageText }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ConversationFragment.NewestMessage.self,
          MessageFragment.self,
          MessageFragment.AsChatMessageText.self,
          ChatMessageTextFragment.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationFragment.NewestMessage.self,
          ConversationFragment.NewestMessage.AsChatMessageText.self,
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

    /// Claim
    ///
    /// Parent Type: `Claim`
    nonisolated public struct Claim: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Claim }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", OctopusGraphQL.ID.self),
        .field("claimType", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationFragment.Claim.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      public var claimType: String? { __data["claimType"] }
    }
  }

}