// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TravelCertificateCreateCoInsured: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      fullName: String,
      ssn: GraphQLNullable<String> = nil,
      dateOfBirth: GraphQLNullable<Date> = nil
    ) {
      __data = InputDict([
        "fullName": fullName,
        "ssn": ssn,
        "dateOfBirth": dateOfBirth
      ])
    }

    public var fullName: String {
      get { __data["fullName"] }
      set { __data["fullName"] = newValue }
    }

    public var ssn: GraphQLNullable<String> {
      get { __data["ssn"] }
      set { __data["ssn"] = newValue }
    }

    public var dateOfBirth: GraphQLNullable<Date> {
      get { __data["dateOfBirth"] }
      set { __data["dateOfBirth"] = newValue }
    }
  }

}