// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct DisplayItemOptions: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      hidePrice: Bool? = nil,
      hideAddons: Bool? = nil
    ) {
      __data = InputDict([
        "hidePrice": hidePrice ?? GraphQLNullable.none,
        "hideAddons": hideAddons ?? GraphQLNullable.none
      ])
    }

    public var hidePrice: Bool? {
      get { __data["hidePrice"] }
      set { __data["hidePrice"] = newValue }
    }

    public var hideAddons: Bool? {
      get { __data["hideAddons"] }
      set { __data["hideAddons"] = newValue }
    }
  }

}