// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractQuery: GraphQLQuery {
    public static let operationName: String = "Contract"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Contract($contractId: UUID!) { contract(id: $contractId) { __typename exposureDisplayName supportsChangeTier } }"#
      ))

    public var contractId: UUID

    public init(contractId: UUID) {
      self.contractId = contractId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["contractId": contractId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("contract", Contract.self, arguments: ["id": .variable("contractId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractQuery.Data.self
      ] }

      /// Resolve a single contract by its ID. Requires the caller to be a member owning said contract.
      public var contract: Contract { __data["contract"] }

      /// Contract
      ///
      /// Parent Type: `Contract`
      nonisolated public struct Contract: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("exposureDisplayName", String.self),
          .field("supportsChangeTier", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ContractQuery.Data.Contract.self
        ] }

        /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
        /// the address of an apartment + number of co insured,
        /// or the person having accident insurance,
        /// or the dog being insured + breed
        /// or car registration number + model etc.
        public var exposureDisplayName: String { __data["exposureDisplayName"] }
        /// Whether or not this contract can be changed through the 'ChangeTier' API.
        public var supportsChangeTier: Bool { __data["supportsChangeTier"] }
      }
    }
  }

}