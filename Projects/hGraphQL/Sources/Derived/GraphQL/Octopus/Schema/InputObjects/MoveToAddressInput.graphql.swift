// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveToAddressInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      street: String,
      postalCode: String,
      city: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "street": street,
        "postalCode": postalCode,
        "city": city
      ])
    }

    ///  The street to move to 
    public var street: String {
      get { __data["street"] }
      set { __data["street"] = newValue }
    }

    ///  The postal code to move to 
    public var postalCode: String {
      get { __data["postalCode"] }
      set { __data["postalCode"] = newValue }
    }

    ///  The city to move to 
    public var city: GraphQLNullable<String> {
      get { __data["city"] }
      set { __data["city"] = newValue }
    }
  }

}