// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeTierDeductibleCommitIntentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      quoteId: ID
    ) {
      __data = InputDict([
        "quoteId": quoteId
      ])
    }

    /// The quote to activate.
    public var quoteId: ID {
      get { __data["quoteId"] }
      set { __data["quoteId"] = newValue }
    }
  }

}