// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct CreateTravelCertificateMutation: GraphQLMutation {
    public static let operationName: String = "CreateTravelCertificate"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateTravelCertificate($input: TravelCertificateCreateInput!) { travelCertificateCreate(input: $input) { __typename id signedUrl startDate endDate } }"#
      ))

    public var input: TravelCertificateCreateInput

    public init(input: TravelCertificateCreateInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("travelCertificateCreate", TravelCertificateCreate.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateTravelCertificateMutation.Data.self
      ] }

      public var travelCertificateCreate: TravelCertificateCreate { __data["travelCertificateCreate"] }

      /// TravelCertificateCreate
      ///
      /// Parent Type: `TravelCertificate`
      nonisolated public struct TravelCertificateCreate: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TravelCertificate }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", OctopusGraphQL.ID.self),
          .field("signedUrl", OctopusGraphQL.Url.self),
          .field("startDate", OctopusGraphQL.Date.self),
          .field("endDate", OctopusGraphQL.Date?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreateTravelCertificateMutation.Data.TravelCertificateCreate.self
        ] }

        public var id: OctopusGraphQL.ID { __data["id"] }
        public var signedUrl: OctopusGraphQL.Url { __data["signedUrl"] }
        public var startDate: OctopusGraphQL.Date { __data["startDate"] }
        public var endDate: OctopusGraphQL.Date? { __data["endDate"] }
      }
    }
  }

}