// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct InsuranceEvidenceCreateMutation: GraphQLMutation {
    public static let operationName: String = "InsuranceEvidenceCreate"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation InsuranceEvidenceCreate($input: InsuranceEvidenceInput!) { insuranceEvidenceCreate(input: $input) { __typename userError { __typename message } insuranceEvidenceInformation { __typename signedUrl } } }"#
      ))

    public var input: InsuranceEvidenceInput

    public init(input: InsuranceEvidenceInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("insuranceEvidenceCreate", InsuranceEvidenceCreate.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        InsuranceEvidenceCreateMutation.Data.self
      ] }

      /// The document includes details of the member’s home insurance,
      /// such as address, coverage duration, payment information, co-insured parties,
      /// and other relevant information for various purposes.
      public var insuranceEvidenceCreate: InsuranceEvidenceCreate { __data["insuranceEvidenceCreate"] }

      /// InsuranceEvidenceCreate
      ///
      /// Parent Type: `InsuranceEvidenceOutput`
      nonisolated public struct InsuranceEvidenceCreate: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.InsuranceEvidenceOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
          .field("insuranceEvidenceInformation", InsuranceEvidenceInformation?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          InsuranceEvidenceCreateMutation.Data.InsuranceEvidenceCreate.self
        ] }

        public var userError: UserError? { __data["userError"] }
        public var insuranceEvidenceInformation: InsuranceEvidenceInformation? { __data["insuranceEvidenceInformation"] }

        /// InsuranceEvidenceCreate.UserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct UserError: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            InsuranceEvidenceCreateMutation.Data.InsuranceEvidenceCreate.UserError.self
          ] }

          public var message: String { __data["message"] }
        }

        /// InsuranceEvidenceCreate.InsuranceEvidenceInformation
        ///
        /// Parent Type: `InsuranceEvidenceInformation`
        nonisolated public struct InsuranceEvidenceInformation: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.InsuranceEvidenceInformation }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("signedUrl", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            InsuranceEvidenceCreateMutation.Data.InsuranceEvidenceCreate.InsuranceEvidenceInformation.self
          ] }

          public var signedUrl: String { __data["signedUrl"] }
        }
      }
    }
  }

}