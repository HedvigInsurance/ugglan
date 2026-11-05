// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationSendMessageMutation: GraphQLMutation {
    public static let operationName: String = "ConversationSendMessage"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ConversationSendMessage($input: ConversationSendMessageInput!) { conversationSendMessage(input: $input) { __typename message { __typename ...MessageFragment } userError { __typename message } } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, MessageFragment.self]
      ))

    public var input: ConversationSendMessageInput

    public init(input: ConversationSendMessageInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("conversationSendMessage", ConversationSendMessage.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationSendMessageMutation.Data.self
      ] }

      public var conversationSendMessage: ConversationSendMessage { __data["conversationSendMessage"] }

      /// ConversationSendMessage
      ///
      /// Parent Type: `ChatMessageMutationOutput`
      nonisolated public struct ConversationSendMessage: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", Message?.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationSendMessageMutation.Data.ConversationSendMessage.self
        ] }

        public var message: Message? { __data["message"] }
        public var userError: UserError? { __data["userError"] }

        /// ConversationSendMessage.Message
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
            ConversationSendMessageMutation.Data.ConversationSendMessage.Message.self,
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

          /// ConversationSendMessage.Message.AsChatMessageFile
          ///
          /// Parent Type: `ChatMessageFile`
          nonisolated public struct AsChatMessageFile: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ConversationSendMessageMutation.Data.ConversationSendMessage.Message
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageFile }
            @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
              ConversationSendMessageMutation.Data.ConversationSendMessage.Message.self,
              MessageFragment.self,
              MessageFragment.AsChatMessageFile.self,
              ChatMessageFileFragment.self
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ConversationSendMessageMutation.Data.ConversationSendMessage.Message.self,
              ConversationSendMessageMutation.Data.ConversationSendMessage.Message.AsChatMessageFile.self,
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

          /// ConversationSendMessage.Message.AsChatMessageText
          ///
          /// Parent Type: `ChatMessageText`
          nonisolated public struct AsChatMessageText: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ConversationSendMessageMutation.Data.ConversationSendMessage.Message
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageText }
            @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
              ConversationSendMessageMutation.Data.ConversationSendMessage.Message.self,
              MessageFragment.self,
              MessageFragment.AsChatMessageText.self,
              ChatMessageTextFragment.self
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ConversationSendMessageMutation.Data.ConversationSendMessage.Message.self,
              ConversationSendMessageMutation.Data.ConversationSendMessage.Message.AsChatMessageText.self,
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

        /// ConversationSendMessage.UserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct UserError: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ConversationSendMessageMutation.Data.ConversationSendMessage.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}