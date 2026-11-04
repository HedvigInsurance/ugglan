// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentFormFieldSearchInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      stepId: ID,
      fieldId: ID,
      query: String
    ) {
      __data = InputDict([
        "stepId": stepId,
        "fieldId": fieldId,
        "query": query
      ])
    }

    public var stepId: ID {
      get { __data["stepId"] }
      set { __data["stepId"] = newValue }
    }

    public var fieldId: ID {
      get { __data["fieldId"] }
      set { __data["fieldId"] = newValue }
    }

    public var query: String {
      get { __data["query"] }
      set { __data["query"] = newValue }
    }
  }

}