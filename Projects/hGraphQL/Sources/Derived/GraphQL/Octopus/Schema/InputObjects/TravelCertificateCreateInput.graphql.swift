// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TravelCertificateCreateInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      contractId: String,
      startDate: Date,
      endDate: GraphQLNullable<Date> = nil,
      isMemberIncluded: Bool,
      coInsured: [TravelCertificateCreateCoInsured],
      email: String
    ) {
      __data = InputDict([
        "contractId": contractId,
        "startDate": startDate,
        "endDate": endDate,
        "isMemberIncluded": isMemberIncluded,
        "coInsured": coInsured,
        "email": email
      ])
    }

    public var contractId: String {
      get { __data["contractId"] }
      set { __data["contractId"] = newValue }
    }

    public var startDate: Date {
      get { __data["startDate"] }
      set { __data["startDate"] = newValue }
    }

    public var endDate: GraphQLNullable<Date> {
      get { __data["endDate"] }
      set { __data["endDate"] = newValue }
    }

    public var isMemberIncluded: Bool {
      get { __data["isMemberIncluded"] }
      set { __data["isMemberIncluded"] = newValue }
    }

    public var coInsured: [TravelCertificateCreateCoInsured] {
      get { __data["coInsured"] }
      set { __data["coInsured"] = newValue }
    }

    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }
  }

}