// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationFlowTerminateContractInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      contractId: ID,
      terminationDate: Date,
      terminationSurveyOptionId: ID,
      terminationComment: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "contractId": contractId,
        "terminationDate": terminationDate,
        "terminationSurveyOptionId": terminationSurveyOptionId,
        "terminationComment": terminationComment
      ])
    }

    public var contractId: ID {
      get { __data["contractId"] }
      set { __data["contractId"] = newValue }
    }

    public var terminationDate: Date {
      get { __data["terminationDate"] }
      set { __data["terminationDate"] = newValue }
    }

    public var terminationSurveyOptionId: ID {
      get { __data["terminationSurveyOptionId"] }
      set { __data["terminationSurveyOptionId"] = newValue }
    }

    public var terminationComment: GraphQLNullable<String> {
      get { __data["terminationComment"] }
      set { __data["terminationComment"] = newValue }
    }
  }

}