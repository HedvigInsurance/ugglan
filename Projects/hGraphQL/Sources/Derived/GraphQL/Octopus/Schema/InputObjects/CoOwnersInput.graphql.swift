// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct CoOwnersInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      firstName: GraphQLNullable<String> = nil,
      lastName: GraphQLNullable<String> = nil,
      ssn: GraphQLNullable<String> = nil,
      birthdate: GraphQLNullable<Date> = nil
    ) {
      __data = InputDict([
        "firstName": firstName,
        "lastName": lastName,
        "ssn": ssn,
        "birthdate": birthdate
      ])
    }

    public var firstName: GraphQLNullable<String> {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    public var lastName: GraphQLNullable<String> {
      get { __data["lastName"] }
      set { __data["lastName"] = newValue }
    }

    public var ssn: GraphQLNullable<String> {
      get { __data["ssn"] }
      set { __data["ssn"] = newValue }
    }

    public var birthdate: GraphQLNullable<Date> {
      get { __data["birthdate"] }
      set { __data["birthdate"] = newValue }
    }
  }

}