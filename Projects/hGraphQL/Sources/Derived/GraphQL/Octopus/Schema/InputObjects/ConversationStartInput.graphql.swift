// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationStartInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      id: UUID
    ) {
      __data = InputDict([
        "id": id
      ])
    }

    /// The to-be `Conversation.id` of the returned Conversation. Should be a UUID v4.
    public var id: UUID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }
  }

}