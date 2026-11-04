// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct InsuranceEvidenceInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      email: String
    ) {
      __data = InputDict([
        "email": email
      ])
    }

    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }
  }

}