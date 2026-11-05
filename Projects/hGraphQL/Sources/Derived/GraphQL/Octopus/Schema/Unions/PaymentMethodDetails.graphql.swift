// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Unions {
  nonisolated static let PaymentMethodDetails = Union(
    name: "PaymentMethodDetails",
    possibleTypes: [
      OctopusGraphQL.Objects.PaymentMethodInvoiceDetails.self,
      OctopusGraphQL.Objects.PaymentMethodSwishDetails.self,
      OctopusGraphQL.Objects.PaymentMethodBankAccountDetails.self
    ]
  )
}