// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  /// Input for memberUpdateContactInfo mutation.
  nonisolated struct MemberUpdateContactInfoInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      phoneNumber: String,
      email: String
    ) {
      __data = InputDict([
        "phoneNumber": phoneNumber,
        "email": email
      ])
    }

    public var phoneNumber: String {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }

    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }
  }

}