// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension OctopusGraphQL {
  /// The status of the charge
  nonisolated enum MemberChargeStatus: String, EnumType {
    /// A charge that is upcoming
    case upcoming = "UPCOMING"
    /// The charge was settled successfully
    case success = "SUCCESS"
    /// The charge is pending that means either has been send to the payment provider
    case pending = "PENDING"
    /// The charge failed
    case failed = "FAILED"
  }

}