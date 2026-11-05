// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Unions {
  nonisolated static let TerminationFlowAction = Union(
    name: "TerminationFlowAction",
    possibleTypes: [
      OctopusGraphQL.Objects.TerminationFlowActionTerminateWithDate.self,
      OctopusGraphQL.Objects.TerminationFlowActionDeleteInsurance.self
    ]
  )
}