// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentSubmitTaskInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      stepId: ID
    ) {
      __data = InputDict([
        "stepId": stepId
      ])
    }

    public var stepId: ID {
      get { __data["stepId"] }
      set { __data["stepId"] = newValue }
    }
  }

}