// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TravelCertificateQuery: GraphQLQuery {
    public static let operationName: String = "TravelCertificate"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query TravelCertificate { currentMember { __typename email firstName lastName activeContracts { __typename id exposureDisplayName exposureDisplayNameShort } travelCertificateSpecifications { __typename contractSpecifications { __typename contractId minStartDate maxStartDate maxDurationDays } } } }"#
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TravelCertificateQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("email", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("activeContracts", [ActiveContract].self),
          .field("travelCertificateSpecifications", TravelCertificateSpecifications.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TravelCertificateQuery.Data.CurrentMember.self
        ] }

        public var email: String { __data["email"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }
        public var travelCertificateSpecifications: TravelCertificateSpecifications { __data["travelCertificateSpecifications"] }

        /// CurrentMember.ActiveContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct ActiveContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.UUID.self),
            .field("exposureDisplayName", String.self),
            .field("exposureDisplayNameShort", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TravelCertificateQuery.Data.CurrentMember.ActiveContract.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment + number of co insured,
          /// or the person having accident insurance,
          /// or the dog being insured + breed
          /// or car registration number + model etc.
          public var exposureDisplayName: String { __data["exposureDisplayName"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment
          /// or the person having accident insurance,
          /// or the dog being insured
          /// or car registration number etc
          public var exposureDisplayNameShort: String { __data["exposureDisplayNameShort"] }
        }

        /// CurrentMember.TravelCertificateSpecifications
        ///
        /// Parent Type: `TravelCertificateSpecification`
        nonisolated public struct TravelCertificateSpecifications: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TravelCertificateSpecification }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("contractSpecifications", [ContractSpecification].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecifications.self
          ] }

          public var contractSpecifications: [ContractSpecification] { __data["contractSpecifications"] }

          /// CurrentMember.TravelCertificateSpecifications.ContractSpecification
          ///
          /// Parent Type: `TravelCertificateContractSpecification`
          nonisolated public struct ContractSpecification: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TravelCertificateContractSpecification }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("contractId", OctopusGraphQL.ID.self),
              .field("minStartDate", OctopusGraphQL.Date.self),
              .field("maxStartDate", OctopusGraphQL.Date.self),
              .field("maxDurationDays", Int.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecifications.ContractSpecification.self
            ] }

            public var contractId: OctopusGraphQL.ID { __data["contractId"] }
            public var minStartDate: OctopusGraphQL.Date { __data["minStartDate"] }
            public var maxStartDate: OctopusGraphQL.Date { __data["maxStartDate"] }
            public var maxDurationDays: Int { __data["maxDurationDays"] }
          }
        }
      }
    }
  }

}