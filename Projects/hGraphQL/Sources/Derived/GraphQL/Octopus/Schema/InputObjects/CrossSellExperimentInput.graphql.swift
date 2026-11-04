// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  /// A/B testing experiment (name and variant must be SCREAMING_SNAKE_CASE)
  nonisolated struct CrossSellExperimentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      name: String,
      variant: String
    ) {
      __data = InputDict([
        "name": name,
        "variant": variant
      ])
    }

    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    public var variant: String {
      get { __data["variant"] }
      set { __data["variant"] = newValue }
    }
  }

}