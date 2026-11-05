// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentSubmitFileUploadInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      stepId: ID,
      fileIds: [ID]
    ) {
      __data = InputDict([
        "stepId": stepId,
        "fileIds": fileIds
      ])
    }

    public var stepId: ID {
      get { __data["stepId"] }
      set { __data["stepId"] = newValue }
    }

    public var fileIds: [ID] {
      get { __data["fileIds"] }
      set { __data["fileIds"] = newValue }
    }
  }

}