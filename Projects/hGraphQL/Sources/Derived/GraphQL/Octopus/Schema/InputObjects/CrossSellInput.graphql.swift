// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct CrossSellInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      userFlow: GraphQLEnum<UserFlow>,
      flowSource: GraphQLNullable<GraphQLEnum<FlowSource>> = nil,
      experiments: [CrossSellExperimentInput],
      contractId: GraphQLNullable<ID> = nil,
      claimId: GraphQLNullable<UUID> = nil
    ) {
      __data = InputDict([
        "userFlow": userFlow,
        "flowSource": flowSource,
        "experiments": experiments,
        "contractId": contractId,
        "claimId": claimId
      ])
    }

    public var userFlow: GraphQLEnum<UserFlow> {
      get { __data["userFlow"] }
      set { __data["userFlow"] = newValue }
    }

    /// REQUIRED for SMART_X_SELL, must be NULL for HOME_X_SELL, INSURANCES, ONBOARDING and HOME
    public var flowSource: GraphQLNullable<GraphQLEnum<FlowSource>> {
      get { __data["flowSource"] }
      set { __data["flowSource"] = newValue }
    }

    /// A/B test experiments for attribution tracking. ACCIDENT_DISCOUNT with variant NO_DISCOUNT withholds the accident
    /// cross-sell's discount.
    public var experiments: [CrossSellExperimentInput] {
      get { __data["experiments"] }
      set { __data["experiments"] = newValue }
    }

    /// The contract that was changed in the flow. When set, enables addon recommendations for that contract.
    public var contractId: GraphQLNullable<ID> {
      get { __data["contractId"] }
      set { __data["contractId"] = newValue }
    }

    /// The claim this flow relates to. Only allowed when flowSource is CLOSED_CLAIM.
    public var claimId: GraphQLNullable<UUID> {
      get { __data["claimId"] }
      set { __data["claimId"] = newValue }
    }
  }

}