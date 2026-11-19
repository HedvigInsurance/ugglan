// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MessageContentQuery: GraphQLQuery {
    public static let operationName: String = "MessageContent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MessageContent($messageId: ID!) { currentMember { __typename cioMessageContent(messageId: $messageId) { __typename content preheader } } }"#
      ))

    public var messageId: ID

    public init(messageId: ID) {
      self.messageId = messageId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["messageId": messageId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MessageContentQuery.Data.self
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
          .field("cioMessageContent", CioMessageContent?.self, arguments: ["messageId": .variable("messageId")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MessageContentQuery.Data.CurrentMember.self
        ] }

        /// The rendered content of one of this member's deliveries. Fetched from Customer.io the first
        /// time and served from our own database afterwards.
        public var cioMessageContent: CioMessageContent? { __data["cioMessageContent"] }

        /// CurrentMember.CioMessageContent
        ///
        /// Parent Type: `CioMessageContent`
        nonisolated public struct CioMessageContent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.CioMessageContent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("content", String.self),
            .field("preheader", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MessageContentQuery.Data.CurrentMember.CioMessageContent.self
          ] }

          /// The rendered message body.
          public var content: String { __data["content"] }
          /// Email "preview text". Null for non-email messages, and for messages cached before we stored it.
          public var preheader: String? { __data["preheader"] }
        }
      }
    }
  }

}