// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationsTimeStampQuery: GraphQLQuery {
    public static let operationName: String = "ConversationsTimeStamp"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ConversationsTimeStamp { currentMember { __typename conversations { __typename id newestMessage { __typename sentAt } unreadMessageCount } legacyConversation { __typename id newestMessage { __typename sentAt } unreadMessageCount } } }"#
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
        ConversationsTimeStampQuery.Data.self
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
          ConversationsTimeStampQuery.Data.CurrentMember.self
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
            .field("id", OctopusGraphQL.UUID.self),
            .field("newestMessage", NewestMessage?.self),
            .field("unreadMessageCount", Int.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConversationsTimeStampQuery.Data.CurrentMember.Conversation.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          public var newestMessage: NewestMessage? { __data["newestMessage"] }
          public var unreadMessageCount: Int { __data["unreadMessageCount"] }

          /// CurrentMember.Conversation.NewestMessage
          ///
          /// Parent Type: `ChatMessage`
          nonisolated public struct NewestMessage: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Interfaces.ChatMessage }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("sentAt", OctopusGraphQL.Instant.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ConversationsTimeStampQuery.Data.CurrentMember.Conversation.NewestMessage.self
            ] }

            public var sentAt: OctopusGraphQL.Instant { __data["sentAt"] }
          }
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
            .field("id", OctopusGraphQL.UUID.self),
            .field("newestMessage", NewestMessage?.self),
            .field("unreadMessageCount", Int.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConversationsTimeStampQuery.Data.CurrentMember.LegacyConversation.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          public var newestMessage: NewestMessage? { __data["newestMessage"] }
          public var unreadMessageCount: Int { __data["unreadMessageCount"] }

          /// CurrentMember.LegacyConversation.NewestMessage
          ///
          /// Parent Type: `ChatMessage`
          nonisolated public struct NewestMessage: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Interfaces.ChatMessage }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("sentAt", OctopusGraphQL.Instant.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ConversationsTimeStampQuery.Data.CurrentMember.LegacyConversation.NewestMessage.self
            ] }

            public var sentAt: OctopusGraphQL.Instant { __data["sentAt"] }
          }
        }
      }
    }
  }

}