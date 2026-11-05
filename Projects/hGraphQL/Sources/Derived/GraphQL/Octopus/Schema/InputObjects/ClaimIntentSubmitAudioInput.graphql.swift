// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentSubmitAudioInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      stepId: ID,
      audioFileId: GraphQLNullable<ID> = nil,
      freeText: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "stepId": stepId,
        "audioFileId": audioFileId,
        "freeText": freeText
      ])
    }

    public var stepId: ID {
      get { __data["stepId"] }
      set { __data["stepId"] = newValue }
    }

    public var audioFileId: GraphQLNullable<ID> {
      get { __data["audioFileId"] }
      set { __data["audioFileId"] = newValue }
    }

    public var freeText: GraphQLNullable<String> {
      get { __data["freeText"] }
      set { __data["freeText"] = newValue }
    }
  }

}