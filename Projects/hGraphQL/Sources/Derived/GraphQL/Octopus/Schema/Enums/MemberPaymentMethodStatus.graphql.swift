// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated enum MemberPaymentMethodStatus: String, EnumType {
    /// The payment connection is active and can be used for payins or payouts.
    case active = "ACTIVE"
    /// The payment connection has been partially set up but is awaiting activation.
    case pending = "PENDING"
  }

}