// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationMessagesQuery: GraphQLQuery {
    public static let operationName: String = "ConversationMessages"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ConversationMessages($conversationId: UUID!, $olderToken: String, $newerToken: String) { conversation(id: $conversationId) { __typename id isOpen messagePage(olderToken: $olderToken, newerToken: $newerToken) { __typename ...MessagePageFragment } responseIsBeingGenerated showCrossSales statusMessage createdAt isLegacy claim { __typename id claimType } } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, MessageFragment.self, MessagePageFragment.self]
      ))

    public var conversationId: UUID
    public var olderToken: GraphQLNullable<String>
    public var newerToken: GraphQLNullable<String>

    public init(
      conversationId: UUID,
      olderToken: GraphQLNullable<String>,
      newerToken: GraphQLNullable<String>
    ) {
      self.conversationId = conversationId
      self.olderToken = olderToken
      self.newerToken = newerToken
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "conversationId": conversationId,
      "olderToken": olderToken,
      "newerToken": newerToken
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("conversation", Conversation?.self, arguments: ["id": .variable("conversationId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationMessagesQuery.Data.self
      ] }

      /// Return a conversation for a given ID.
      ///
      /// Note that this can return null if `Mutation.conversationStart` has not been called with this ID.
      public var conversation: Conversation? { __data["conversation"] }

      /// Conversation
      ///
      /// Parent Type: `Conversation`
      nonisolated public struct Conversation: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", OctopusGraphQL.UUID.self),
          .field("isOpen", Bool.self),
          .field("messagePage", MessagePage.self, arguments: [
            "olderToken": .variable("olderToken"),
            "newerToken": .variable("newerToken")
          ]),
          .field("responseIsBeingGenerated", Bool.self),
          .field("showCrossSales", Bool.self),
          .field("statusMessage", String?.self),
          .field("createdAt", OctopusGraphQL.DateTime.self),
          .field("isLegacy", Bool.self),
          .field("claim", Claim?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationMessagesQuery.Data.Conversation.self
        ] }

        public var id: OctopusGraphQL.UUID { __data["id"] }
        public var isOpen: Bool { __data["isOpen"] }
        public var messagePage: MessagePage { __data["messagePage"] }
        public var responseIsBeingGenerated: Bool { __data["responseIsBeingGenerated"] }
        /// Whether to surface cross sales to the member in this conversation.
        ///
        /// Show the prompt while this is `true`, and call `Mutation.conversationHideCrossSales`
        /// when the member dismisses it.
        public var showCrossSales: Bool { __data["showCrossSales"] }
        public var statusMessage: String? { __data["statusMessage"] }
        public var createdAt: OctopusGraphQL.DateTime { __data["createdAt"] }
        public var isLegacy: Bool { __data["isLegacy"] }
        /// Return the claim for this conversation, if it has one.
        ///
        /// Conversations auto-created when a claim is opened will have this, others will not.
        /// The `legacyConversation` will not have any associated claim.
        public var claim: Claim? { __data["claim"] }

        /// Conversation.MessagePage
        ///
        /// Parent Type: `ChatMessagePage`
        nonisolated public struct MessagePage: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessagePage }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MessagePageFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConversationMessagesQuery.Data.Conversation.MessagePage.self,
            MessagePageFragment.self
          ] }

          public var messages: [Message] { __data["messages"] }
          public var newerToken: String? { __data["newerToken"] }
          public var olderToken: String? { __data["olderToken"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var messagePageFragment: MessagePageFragment { _toFragment() }
          }

          public typealias Message = MessagePageFragment.Message
        }

        /// Conversation.Claim
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
            ConversationMessagesQuery.Data.Conversation.Claim.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          public var claimType: String? { __data["claimType"] }
        }
      }
    }
  }

}