// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeTierDeductibleCreateIntentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      contractId: ID,
      source: GraphQLEnum<ChangeTierDeductibleSource>
    ) {
      __data = InputDict([
        "contractId": contractId,
        "source": source
      ])
    }

    /// The contract to change.
    public var contractId: ID {
      get { __data["contractId"] }
      set { __data["contractId"] = newValue }
    }

    /// The source for changing tier/deductible.
    public var source: GraphQLEnum<ChangeTierDeductibleSource> {
      get { __data["source"] }
      set { __data["source"] = newValue }
    }
  }

}