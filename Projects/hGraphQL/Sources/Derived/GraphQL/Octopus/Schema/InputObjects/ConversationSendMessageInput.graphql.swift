// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ConversationSendMessageInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      id: UUID,
      messageId: GraphQLNullable<UUID> = nil,
      text: GraphQLNullable<String> = nil,
      fileUploadToken: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "id": id,
        "messageId": messageId,
        "text": text,
        "fileUploadToken": fileUploadToken
      ])
    }

    /// The conversation ID the message should be sent to
    public var id: UUID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }

    /// Optional client-generated ID for the message
    public var messageId: GraphQLNullable<UUID> {
      get { __data["messageId"] }
      set { __data["messageId"] = newValue }
    }

    public var text: GraphQLNullable<String> {
      get { __data["text"] }
      set { __data["text"] = newValue }
    }

    public var fileUploadToken: GraphQLNullable<String> {
      get { __data["fileUploadToken"] }
      set { __data["fileUploadToken"] = newValue }
    }
  }

}