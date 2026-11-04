// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ProfileQuery: GraphQLQuery {
    public static let operationName: String = "Profile"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Profile { currentMember { __typename memberActions { __typename isTravelCertificateEnabled isCreatingOfInsuranceEvidenceEnabled isContactInfoUpdateNeeded } travelCertificates { __typename id } id email phoneNumber firstName lastName ...PartnerDataFragment } }"#,
        fragments: [PartnerDataFragment.self]
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
        ProfileQuery.Data.self
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
          .field("travelCertificates", [TravelCertificate].self),
          .field("id", OctopusGraphQL.ID.self),
          .field("email", String.self),
          .field("phoneNumber", String?.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .fragment(PartnerDataFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProfileQuery.Data.CurrentMember.self,
          PartnerDataFragment.self
        ] }

        public var memberActions: MemberActions? { __data["memberActions"] }
        public var travelCertificates: [TravelCertificate] { __data["travelCertificates"] }
        public var id: OctopusGraphQL.ID { __data["id"] }
        public var email: String { __data["email"] }
        public var phoneNumber: String? { __data["phoneNumber"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var partnerData: PartnerData? { __data["partnerData"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var partnerDataFragment: PartnerDataFragment { _toFragment() }
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
            .field("isTravelCertificateEnabled", Bool?.self),
            .field("isCreatingOfInsuranceEvidenceEnabled", Bool.self),
            .field("isContactInfoUpdateNeeded", Bool.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProfileQuery.Data.CurrentMember.MemberActions.self
          ] }

          /// Indicate whether the travel certificate option should be displayed.
          public var isTravelCertificateEnabled: Bool? { __data["isTravelCertificateEnabled"] }
          /// Indicate whether the possibility to create insurance evidence should be displayed.
          public var isCreatingOfInsuranceEvidenceEnabled: Bool { __data["isCreatingOfInsuranceEvidenceEnabled"] }
          /// Indicates that the member should review their phone number or add if it is missing.
          public var isContactInfoUpdateNeeded: Bool { __data["isContactInfoUpdateNeeded"] }
        }

        /// CurrentMember.TravelCertificate
        ///
        /// Parent Type: `TravelCertificate`
        nonisolated public struct TravelCertificate: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TravelCertificate }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.ID.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProfileQuery.Data.CurrentMember.TravelCertificate.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
        }

        public typealias PartnerData = PartnerDataFragment.PartnerData
      }
    }
  }

}