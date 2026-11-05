// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationStartMutation: GraphQLMutation {
    public static let operationName: String = "ConversationStart"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ConversationStart($input: ConversationStartInput!) { conversationStart(input: $input) { __typename ...ConversationFragment } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, ConversationFragment.self, MessageFragment.self]
      ))

    public var input: ConversationStartInput

    public init(input: ConversationStartInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("conversationStart", ConversationStart.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationStartMutation.Data.self
      ] }

      /// Start a conversation. This is effectively creating one, but with two slight differences from a regular
      /// "create something"-mutation:
      /// - It lets the clients inject the ID of the conversation, which is useful for the implementation for some clients
      /// - It is idempotent, so starting it again will simply return the old one unchanged
      public var conversationStart: ConversationStart { __data["conversationStart"] }

      /// ConversationStart
      ///
      /// Parent Type: `Conversation`
      nonisolated public struct ConversationStart: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ConversationFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationStartMutation.Data.ConversationStart.self,
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