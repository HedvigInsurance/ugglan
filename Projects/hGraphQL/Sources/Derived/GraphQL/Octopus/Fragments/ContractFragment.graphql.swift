// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ContractFragment on Contract { __typename currentAgreement { __typename ...AgreementFragment } coInsured { __typename ...CoInsuredFragment } coOwners { __typename ...CoOwnerFragment } exposureDisplayName exposureDisplayNameShort id masterInceptionDate supportsMoving supportsCoInsured supportsCoOwners supportsTravelCertificate supportsChangeTier supportsTermination terminationDate upcomingChangedAgreement { __typename ...AgreementFragment } isMissingPetId }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("currentAgreement", CurrentAgreement.self),
      .field("coInsured", [CoInsured]?.self),
      .field("coOwners", [CoOwner]?.self),
      .field("exposureDisplayName", String.self),
      .field("exposureDisplayNameShort", String.self),
      .field("id", OctopusGraphQL.UUID.self),
      .field("masterInceptionDate", OctopusGraphQL.Date.self),
      .field("supportsMoving", Bool.self),
      .field("supportsCoInsured", Bool.self),
      .field("supportsCoOwners", Bool.self),
      .field("supportsTravelCertificate", Bool.self),
      .field("supportsChangeTier", Bool.self),
      .field("supportsTermination", Bool.self),
      .field("terminationDate", OctopusGraphQL.Date?.self),
      .field("upcomingChangedAgreement", UpcomingChangedAgreement?.self),
      .field("isMissingPetId", Bool.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// CurrentAgreement
    ///
    /// Parent Type: `Agreement`
    nonisolated public struct CurrentAgreement: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(AgreementFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractFragment.CurrentAgreement.self,
        AgreementFragment.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      /// The date this agreement took effect.
      public var activeFrom: OctopusGraphQL.Date { __data["activeFrom"] }
      /// The last date this is in effect.
      public var activeTo: OctopusGraphQL.Date { __data["activeTo"] }
      /// The URL of the insurance certificate.
      public var certificateUrl: OctopusGraphQL.Url? { __data["certificateUrl"] }
      /// The reason this agreement was created, useful to distinguish between renewals and other creations for instance.
      public var creationCause: GraphQLEnum<OctopusGraphQL.AgreementCreationCause> { __data["creationCause"] }
      /// The monthly premium of this agreement.
      public var basePremium: BasePremium { __data["basePremium"] }
      /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
      /// such as names, legal documents, perils etc.
      public var productVariant: ProductVariant { __data["productVariant"] }
      /// List of addons on the agreement.
      public var addons: [Addon] { __data["addons"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var agreementFragment: AgreementFragment { _toFragment() }
      }

      public typealias BasePremium = AgreementFragment.BasePremium

      public typealias ProductVariant = AgreementFragment.ProductVariant

      public typealias Addon = AgreementFragment.Addon
    }

    /// CoInsured
    ///
    /// Parent Type: `ContractCoInsured`
    nonisolated public struct CoInsured: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractCoInsured }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(CoInsuredFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractFragment.CoInsured.self,
        CoInsuredFragment.self
      ] }

      /// firstName + lastName + birthDate if all are present, otherwise null
      public var id: OctopusGraphQL.ID? { __data["id"] }
      /// Co-insured birthdate.
      public var birthdate: OctopusGraphQL.Date? { __data["birthdate"] }
      /// First name.
      public var firstName: String? { __data["firstName"] }
      /// Last name.
      public var lastName: String? { __data["lastName"] }
      /// Whether or not any of firstName, lastName, ssn or birthdate is missing and needs to be added.
      public var hasMissingInfo: Bool { __data["hasMissingInfo"] }
      /// National identification number if any.
      public var ssn: String? { __data["ssn"] }
      /// The date this co-insured will be added.
      public var activatesOn: OctopusGraphQL.Date? { __data["activatesOn"] }
      /// The date this co-insured will be removed.
      public var terminatesOn: OctopusGraphQL.Date? { __data["terminatesOn"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var coInsuredFragment: CoInsuredFragment { _toFragment() }
      }
    }

    /// CoOwner
    ///
    /// Parent Type: `ContractCoOwner`
    nonisolated public struct CoOwner: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractCoOwner }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(CoOwnerFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractFragment.CoOwner.self,
        CoOwnerFragment.self
      ] }

      /// firstName + lastName + birthDate if all are present, otherwise null
      public var id: OctopusGraphQL.ID? { __data["id"] }
      /// Co-insured birthdate.
      public var birthdate: OctopusGraphQL.Date? { __data["birthdate"] }
      /// First name.
      public var firstName: String? { __data["firstName"] }
      /// Last name.
      public var lastName: String? { __data["lastName"] }
      /// Whether or not any of firstName, lastName, ssn or birthdate is missing and needs to be added.
      public var hasMissingInfo: Bool { __data["hasMissingInfo"] }
      /// National identification number if any.
      public var ssn: String? { __data["ssn"] }
      /// The date this co-insured will be added.
      public var activatesOn: OctopusGraphQL.Date? { __data["activatesOn"] }
      /// The date this co-insured will be removed.
      public var terminatesOn: OctopusGraphQL.Date? { __data["terminatesOn"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var coOwnerFragment: CoOwnerFragment { _toFragment() }
      }
    }

    /// UpcomingChangedAgreement
    ///
    /// Parent Type: `Agreement`
    nonisolated public struct UpcomingChangedAgreement: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(AgreementFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractFragment.UpcomingChangedAgreement.self,
        AgreementFragment.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      /// The date this agreement took effect.
      public var activeFrom: OctopusGraphQL.Date { __data["activeFrom"] }
      /// The last date this is in effect.
      public var activeTo: OctopusGraphQL.Date { __data["activeTo"] }
      /// The URL of the insurance certificate.
      public var certificateUrl: OctopusGraphQL.Url? { __data["certificateUrl"] }
      /// The reason this agreement was created, useful to distinguish between renewals and other creations for instance.
      public var creationCause: GraphQLEnum<OctopusGraphQL.AgreementCreationCause> { __data["creationCause"] }
      /// The monthly premium of this agreement.
      public var basePremium: BasePremium { __data["basePremium"] }
      /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
      /// such as names, legal documents, perils etc.
      public var productVariant: ProductVariant { __data["productVariant"] }
      /// List of addons on the agreement.
      public var addons: [Addon] { __data["addons"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var agreementFragment: AgreementFragment { _toFragment() }
      }

      public typealias BasePremium = AgreementFragment.BasePremium

      public typealias ProductVariant = AgreementFragment.ProductVariant

      public typealias Addon = AgreementFragment.Addon
    }
  }

}