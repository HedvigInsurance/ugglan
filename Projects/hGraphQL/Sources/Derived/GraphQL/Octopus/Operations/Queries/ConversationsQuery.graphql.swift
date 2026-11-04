// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationsQuery: GraphQLQuery {
    public static let operationName: String = "Conversations"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Conversations { currentMember { __typename conversations { __typename ...ConversationFragment } legacyConversation { __typename ...ConversationFragment } } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, ConversationFragment.self, MessageFragment.self]
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationsQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("conversations", [Conversation].self),
          .field("legacyConversation", LegacyConversation?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationsQuery.Data.CurrentMember.self
        ] }

        public var conversations: [Conversation] { __data["conversations"] }
        public var legacyConversation: LegacyConversation? { __data["legacyConversation"] }

        /// CurrentMember.Conversation
        ///
        /// Parent Type: `Conversation`
        nonisolated public struct Conversation: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ConversationFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConversationsQuery.Data.CurrentMember.Conversation.self,
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

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var conversationFragment: ConversationFragment { _toFragment() }
          }

          public typealias NewestMessage = ConversationFragment.NewestMessage

          public typealias Claim = ConversationFragment.Claim
        }

        /// CurrentMember.LegacyConversation
        ///
        /// Parent Type: `Conversation`
        nonisolated public struct LegacyConversation: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ConversationFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConversationsQuery.Data.CurrentMember.LegacyConversation.self,
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

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var conversationFragment: ConversationFragment { _toFragment() }
          }

          public typealias NewestMessage = ConversationFragment.NewestMessage

          public typealias Claim = ConversationFragment.Claim
        }
      }
    }
  }

}