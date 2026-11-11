// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct HomeQuery: GraphQLQuery {
    public static let operationName: String = "Home"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Home { currentMember { __typename id firstName activeContracts { __typename ...ContractFragment } pendingContracts { __typename externalInsuranceCancellationHandledByHedvig exposureDisplayName id } importantMessages { __typename id message linkInfo { __typename buttonText url } } memberActions { __typename sickAbroadDeflect { __typename ...DeflectFragment } isTravelCertificateEnabled isMovingEnabled isConnectPaymentEnabled isEditCoInsuredEnabled isEditCoOwnersEnabled isCancelInsuranceEnabled isContactInfoUpdateNeeded isChangeTierEnabled firstVetAction { __typename sections { __typename buttonTitle description url title } } } } }"#,
        fragments: [AddonVariantFragment.self, AgreementFragment.self, ClaimIntentOutcomeDeflectionPartnerFragment.self, ClaimIntentOutcomeDeflectionSimplePartnerFragment.self, CoInsuredFragment.self, CoOwnerFragment.self, ContractFragment.self, DeflectFragment.self, InsuranceDocumentFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
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
        HomeQuery.Data.self
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
          .field("id", OctopusGraphQL.ID.self),
          .field("firstName", String.self),
          .field("activeContracts", [ActiveContract].self),
          .field("pendingContracts", [PendingContract].self),
          .field("importantMessages", [ImportantMessage].self),
          .field("memberActions", MemberActions?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          HomeQuery.Data.CurrentMember.self
        ] }

        public var id: OctopusGraphQL.ID { __data["id"] }
        public var firstName: String { __data["firstName"] }
        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }
        /// Fetch all the pending contracts for this member.
        public var pendingContracts: [PendingContract] { __data["pendingContracts"] }
        /// Carries messages to be shown to a logged in member, such as possible delays
        /// in service or outage announcements.
        public var importantMessages: [ImportantMessage] { __data["importantMessages"] }
        public var memberActions: MemberActions? { __data["memberActions"] }

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
            HomeQuery.Data.CurrentMember.ActiveContract.self,
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

        /// CurrentMember.PendingContract
        ///
        /// Parent Type: `PendingContract`
        nonisolated public struct PendingContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PendingContract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("externalInsuranceCancellationHandledByHedvig", Bool.self),
            .field("exposureDisplayName", String.self),
            .field("id", OctopusGraphQL.UUID.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            HomeQuery.Data.CurrentMember.PendingContract.self
          ] }

          /// A value indicating whether Hedvig will help out with the cancellation of the member's existing insurance (true)
          /// or if the member have to cancel it themselves and get back to us with a requested start date (false).
          public var externalInsuranceCancellationHandledByHedvig: Bool { __data["externalInsuranceCancellationHandledByHedvig"] }
          /// Same as `Contract.exposureDisplayName`.
          public var exposureDisplayName: String { __data["exposureDisplayName"] }
          public var id: OctopusGraphQL.UUID { __data["id"] }
        }

        /// CurrentMember.ImportantMessage
        ///
        /// Parent Type: `MemberImportantMessage`
        nonisolated public struct ImportantMessage: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberImportantMessage }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.ID.self),
            .field("message", String.self),
            .field("linkInfo", LinkInfo?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            HomeQuery.Data.CurrentMember.ImportantMessage.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          public var message: String { __data["message"] }
          public var linkInfo: LinkInfo? { __data["linkInfo"] }

          /// CurrentMember.ImportantMessage.LinkInfo
          ///
          /// Parent Type: `LinkInfo`
          nonisolated public struct LinkInfo: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.LinkInfo }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("buttonText", String.self),
              .field("url", OctopusGraphQL.Url.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              HomeQuery.Data.CurrentMember.ImportantMessage.LinkInfo.self
            ] }

            public var buttonText: String { __data["buttonText"] }
            public var url: OctopusGraphQL.Url { __data["url"] }
          }
        }

        /// CurrentMember.MemberActions
        ///
        /// Parent Type: `MemberActions`
        nonisolated public struct MemberActions: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberActions }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sickAbroadDeflect", SickAbroadDeflect?.self),
            .field("isTravelCertificateEnabled", Bool?.self),
            .field("isMovingEnabled", Bool.self),
            .field("isConnectPaymentEnabled", Bool.self),
            .field("isEditCoInsuredEnabled", Bool.self),
            .field("isEditCoOwnersEnabled", Bool.self),
            .field("isCancelInsuranceEnabled", Bool.self),
            .field("isContactInfoUpdateNeeded", Bool.self),
            .field("isChangeTierEnabled", Bool.self),
            .field("firstVetAction", FirstVetAction?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            HomeQuery.Data.CurrentMember.MemberActions.self
          ] }

          /// Returns a deflection to emergency partners if the member has an active contract that includes travel insurance coverage.
          /// Reuses the ClaimIntentStepContentDeflection type for convenience.
          public var sickAbroadDeflect: SickAbroadDeflect? { __data["sickAbroadDeflect"] }
          /// Indicate whether the travel certificate option should be displayed.
          public var isTravelCertificateEnabled: Bool? { __data["isTravelCertificateEnabled"] }
          public var isMovingEnabled: Bool { __data["isMovingEnabled"] }
          public var isConnectPaymentEnabled: Bool { __data["isConnectPaymentEnabled"] }
          public var isEditCoInsuredEnabled: Bool { __data["isEditCoInsuredEnabled"] }
          public var isEditCoOwnersEnabled: Bool { __data["isEditCoOwnersEnabled"] }
          public var isCancelInsuranceEnabled: Bool { __data["isCancelInsuranceEnabled"] }
          /// Indicates that the member should review their phone number or add if it is missing.
          public var isContactInfoUpdateNeeded: Bool { __data["isContactInfoUpdateNeeded"] }
          public var isChangeTierEnabled: Bool { __data["isChangeTierEnabled"] }
          public var firstVetAction: FirstVetAction? { __data["firstVetAction"] }

          /// CurrentMember.MemberActions.SickAbroadDeflect
          ///
          /// Parent Type: `ClaimIntentStepContentDeflection`
          nonisolated public struct SickAbroadDeflect: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflection }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(DeflectFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              HomeQuery.Data.CurrentMember.MemberActions.SickAbroadDeflect.self,
              DeflectFragment.self
            ] }

            public var infoText: String? { __data["infoText"] }
            public var warningText: String? { __data["warningText"] }
            public var partnersInfo: PartnersInfo? { __data["partnersInfo"] }
            public var content: Content { __data["content"] }
            public var faq: [Faq] { __data["faq"] }
            public var title: String? { __data["title"] }
            public var partners: [Partner] { __data["partners"] }
            public var simplePartners: [SimplePartner] { __data["simplePartners"] }
            public var buttonTitle: String { __data["buttonTitle"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var deflectFragment: DeflectFragment { _toFragment() }
            }

            public typealias PartnersInfo = DeflectFragment.PartnersInfo

            public typealias Content = DeflectFragment.Content

            public typealias Faq = DeflectFragment.Faq

            public typealias Partner = DeflectFragment.Partner

            public typealias SimplePartner = DeflectFragment.SimplePartner
          }

          /// CurrentMember.MemberActions.FirstVetAction
          ///
          /// Parent Type: `FirstVetAction`
          nonisolated public struct FirstVetAction: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.FirstVetAction }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("sections", [Section].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              HomeQuery.Data.CurrentMember.MemberActions.FirstVetAction.self
            ] }

            public var sections: [Section] { __data["sections"] }

            /// CurrentMember.MemberActions.FirstVetAction.Section
            ///
            /// Parent Type: `FirstVetSection`
            nonisolated public struct Section: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.FirstVetSection }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("buttonTitle", String?.self),
                .field("description", String?.self),
                .field("url", String?.self),
                .field("title", String?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                HomeQuery.Data.CurrentMember.MemberActions.FirstVetAction.Section.self
              ] }

              public var buttonTitle: String? { __data["buttonTitle"] }
              public var description: String? { __data["description"] }
              public var url: String? { __data["url"] }
              public var title: String? { __data["title"] }
            }
          }
        }
      }
    }
  }

}