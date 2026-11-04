// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated enum PaymentMethodSetupStatus: String, EnumType {
    ///  The payment method setup process is completed and the payment method is ready to use. 
    case active = "ACTIVE"
    ///  The payment method setup process is still ongoing. 
    case pending = "PENDING"
    ///  The payment method setup process has failed. 
    case failed = "FAILED"
  }

}