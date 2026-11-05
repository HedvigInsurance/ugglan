// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationHideCrossSalesMutation: GraphQLMutation {
    public static let operationName: String = "ConversationHideCrossSales"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ConversationHideCrossSales($id: UUID!) { conversationHideCrossSales(id: $id) { __typename id showCrossSales } }"#
      ))

    public var id: UUID

    public init(id: UUID) {
      self.id = id
    }

    @_spi(Unsafe) public var __variables: Variables? { ["id": id] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("conversationHideCrossSales", ConversationHideCrossSales.self, arguments: ["id": .variable("id")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConversationHideCrossSalesMutation.Data.self
      ] }

      /// Stop showing cross sales in a conversation, for good. Idempotent.
      public var conversationHideCrossSales: ConversationHideCrossSales { __data["conversationHideCrossSales"] }

      /// ConversationHideCrossSales
      ///
      /// Parent Type: `Conversation`
      nonisolated public struct ConversationHideCrossSales: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", OctopusGraphQL.UUID.self),
          .field("showCrossSales", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ConversationHideCrossSalesMutation.Data.ConversationHideCrossSales.self
        ] }

        public var id: OctopusGraphQL.UUID { __data["id"] }
        /// Whether to surface cross sales to the member in this conversation.
        ///
        /// Show the prompt while this is `true`, and call `Mutation.conversationHideCrossSales`
        /// when the member dismisses it.
        public var showCrossSales: Bool { __data["showCrossSales"] }
      }
    }
  }

}