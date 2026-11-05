// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodSetupTrustlyInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      successUrl: String,
      failureUrl: String
    ) {
      __data = InputDict([
        "successUrl": successUrl,
        "failureUrl": failureUrl
      ])
    }

    ///  The URL to redirect the member back to after a successful setup after Trustly onboarding. 
    public var successUrl: String {
      get { __data["successUrl"] }
      set { __data["successUrl"] = newValue }
    }

    ///  The URL to redirect the member back to after a failed setup after Trustly onboarding. 
    public var failureUrl: String {
      get { __data["failureUrl"] }
      set { __data["failureUrl"] = newValue }
    }
  }

}