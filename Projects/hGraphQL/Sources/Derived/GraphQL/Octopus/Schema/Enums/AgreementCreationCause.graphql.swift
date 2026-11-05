// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated enum AgreementCreationCause: String, EnumType {
    /// No creation cause is known - this is due to the agreement being older than when we started tracking
    /// creation cause.
    case unknown = "UNKNOWN"
    /// This agreement was created as part of a contract creation. This means it's the first agreement of said contract.
    case newContract = "NEW_CONTRACT"
    /// This agreement was created as part of the automatic renewal process of insurances. Usually yearly.
    case renewal = "RENEWAL"
    /// This agreement was created by some kind of intervening change to the insurance, such as a move, co-insured change
    /// or similar.
    case midtermChange = "MIDTERM_CHANGE"
  }

}