// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractsQuery: GraphQLQuery {
    public static let operationName: String = "Contracts"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Contracts { currentMember { __typename firstName lastName ssn activeContracts { __typename ...ContractFragment } } }"#,
        fragments: [AddonVariantFragment.self, AgreementFragment.self, CoInsuredFragment.self, CoOwnerFragment.self, ContractFragment.self, InsuranceDocumentFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
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
        ContractsQuery.Data.self
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
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("ssn", String?.self),
          .field("activeContracts", [ActiveContract].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ContractsQuery.Data.CurrentMember.self
        ] }

        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var ssn: String? { __data["ssn"] }
        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }

        /// CurrentMember.ActiveContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct ActiveContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ContractFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ContractsQuery.Data.CurrentMember.ActiveContract.self,
            ContractFragment.self
          ] }

          /// The currently active/relevant agreement for this contract.
          public var currentAgreement: CurrentAgreement { __data["currentAgreement"] }
          /// Current state of co-insured including upcoming changes.
          /// If current agreement doesn't support co-insured, this is null
          public var coInsured: [CoInsured]? { __data["coInsured"] }
          /// Current state of co-owners including upcoming changes.
          /// If current agreement doesn't support co-owners, this is null
          /// Reuses ContractCoInsured type, for now.
          public var coOwners: [CoOwner]? { __data["coOwners"] }
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
          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// The first date this insurance became active - i.e. the "from date" of the first agreement.
          public var masterInceptionDate: OctopusGraphQL.Date { __data["masterInceptionDate"] }
          /// Whether or not this contract can be changes through the 'MoveIntent' API.
          public var supportsMoving: Bool { __data["supportsMoving"] }
          /// Whether or not this co-insured for contract can be changed through the 'MidtermChange' API.
          public var supportsCoInsured: Bool { __data["supportsCoInsured"] }
          /// Whether or not this co-insured for contract can be changed through the 'MidtermChange' API.
          public var supportsCoOwners: Bool { __data["supportsCoOwners"] }
          /// Whether or not travel certificate can be created for the contract
          public var supportsTravelCertificate: Bool { __data["supportsTravelCertificate"] }
          /// Whether or not this contract can be changed through the 'ChangeTier' API.
          public var supportsChangeTier: Bool { __data["supportsChangeTier"] }
          /// Whether or not this contract can be terminated by user
          public var supportsTermination: Bool { __data["supportsTermination"] }
          /// The last date this insurance will be active, if there is one.
          public var terminationDate: OctopusGraphQL.Date? { __data["terminationDate"] }
          /// A possible upcoming change of agreement. If there are multiple upcoming changes, this one will return
          /// the first.
          public var upcomingChangedAgreement: UpcomingChangedAgreement? { __data["upcomingChangedAgreement"] }
          /// Checks if petId is missing on the current or upcoming agreement.
          public var isMissingPetId: Bool { __data["isMissingPetId"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var contractFragment: ContractFragment { _toFragment() }
          }

          public typealias CurrentAgreement = ContractFragment.CurrentAgreement

          public typealias CoInsured = ContractFragment.CoInsured

          public typealias CoOwner = ContractFragment.CoOwner

          public typealias UpcomingChangedAgreement = ContractFragment.UpcomingChangedAgreement
        }
      }
    }
  }

}