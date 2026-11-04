// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MidtermChangeIntentCreateInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      coInsuredInputs: GraphQLNullable<[CoInsuredInput]> = nil,
      coOwnersInputs: GraphQLNullable<[CoOwnersInput]> = nil
    ) {
      __data = InputDict([
        "coInsuredInputs": coInsuredInputs,
        "coOwnersInputs": coOwnersInputs
      ])
    }

    /// The list of all co-insured to set on the agreement, i.e. size equals nbrOfCoInsured.
    /// This list contains "null" entries for co-insured not yet defined.
    public var coInsuredInputs: GraphQLNullable<[CoInsuredInput]> {
      get { __data["coInsuredInputs"] }
      set { __data["coInsuredInputs"] = newValue }
    }

    /// The list of all co-owners to set on the agreement.
    /// This list contains "null" entries for co-owners not yet defined.
    public var coOwnersInputs: GraphQLNullable<[CoOwnersInput]> {
      get { __data["coOwnersInputs"] }
      set { __data["coOwnersInputs"] = newValue }
    }
  }

}