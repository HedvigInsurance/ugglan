// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodSetupNordeaPayoutInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      accountNumber: String
    ) {
      __data = InputDict([
        "accountNumber": accountNumber
      ])
    }

    ///  The account number for member's bank account. 
    public var accountNumber: String {
      get { __data["accountNumber"] }
      set { __data["accountNumber"] = newValue }
    }
  }

}