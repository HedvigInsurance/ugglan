// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TravelCertificatesQuery: GraphQLQuery {
    public static let operationName: String = "TravelCertificates"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query TravelCertificates { currentMember { __typename travelCertificates { __typename startDate id signedUrl expiryDate } activeContracts { __typename supportsTravelCertificate } } }"#
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
        TravelCertificatesQuery.Data.self
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
          .field("travelCertificates", [TravelCertificate].self),
          .field("activeContracts", [ActiveContract].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TravelCertificatesQuery.Data.CurrentMember.self
        ] }

        public var travelCertificates: [TravelCertificate] { __data["travelCertificates"] }
        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }

        /// CurrentMember.TravelCertificate
        ///
        /// Parent Type: `TravelCertificate`
        nonisolated public struct TravelCertificate: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TravelCertificate }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("startDate", OctopusGraphQL.Date.self),
            .field("id", OctopusGraphQL.ID.self),
            .field("signedUrl", OctopusGraphQL.Url.self),
            .field("expiryDate", OctopusGraphQL.Date.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TravelCertificatesQuery.Data.CurrentMember.TravelCertificate.self
          ] }

          public var startDate: OctopusGraphQL.Date { __data["startDate"] }
          public var id: OctopusGraphQL.ID { __data["id"] }
          public var signedUrl: OctopusGraphQL.Url { __data["signedUrl"] }
          public var expiryDate: OctopusGraphQL.Date { __data["expiryDate"] }
        }

        /// CurrentMember.ActiveContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct ActiveContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("supportsTravelCertificate", Bool.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TravelCertificatesQuery.Data.CurrentMember.ActiveContract.self
          ] }

          /// Whether or not travel certificate can be created for the contract
          public var supportsTravelCertificate: Bool { __data["supportsTravelCertificate"] }
        }
      }
    }
  }

}