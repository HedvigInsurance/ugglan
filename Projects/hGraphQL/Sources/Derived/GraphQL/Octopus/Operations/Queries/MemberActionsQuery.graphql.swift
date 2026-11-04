// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberActionsQuery: GraphQLQuery {
    public static let operationName: String = "MemberActions"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MemberActions { currentMember { __typename memberActions { __typename sickAbroadDeflect { __typename ...DeflectFragment } isTravelCertificateEnabled isMovingEnabled isConnectPaymentEnabled isEditCoInsuredEnabled isEditCoOwnersEnabled isCancelInsuranceEnabled isContactInfoUpdateNeeded isChangeTierEnabled firstVetAction { __typename sections { __typename buttonTitle description url title } } } } }"#,
        fragments: [ClaimIntentOutcomeDeflectionPartnerFragment.self, ClaimIntentOutcomeDeflectionSimplePartnerFragment.self, DeflectFragment.self]
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
        MemberActionsQuery.Data.self
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
          .field("memberActions", MemberActions?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberActionsQuery.Data.CurrentMember.self
        ] }

        public var memberActions: MemberActions? { __data["memberActions"] }

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
            MemberActionsQuery.Data.CurrentMember.MemberActions.self
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
              MemberActionsQuery.Data.CurrentMember.MemberActions.SickAbroadDeflect.self,
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
              MemberActionsQuery.Data.CurrentMember.MemberActions.FirstVetAction.self
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
                MemberActionsQuery.Data.CurrentMember.MemberActions.FirstVetAction.Section.self
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