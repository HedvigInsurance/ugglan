// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentSubmitFormInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      stepId: ID,
      fields: [ClaimIntentFormSubmitInputField]
    ) {
      __data = InputDict([
        "stepId": stepId,
        "fields": fields
      ])
    }

    public var stepId: ID {
      get { __data["stepId"] }
      set { __data["stepId"] = newValue }
    }

    public var fields: [ClaimIntentFormSubmitInputField] {
      get { __data["fields"] }
      set { __data["fields"] = newValue }
    }
  }

}