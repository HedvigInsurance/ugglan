// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Unions {
  nonisolated static let ClaimFollowupQuestionContent = Union(
    name: "ClaimFollowupQuestionContent",
    possibleTypes: [
      OctopusGraphQL.Objects.ClaimFollowupBinary.self,
      OctopusGraphQL.Objects.ClaimFollowupFreeText.self,
      OctopusGraphQL.Objects.ClaimFollowupDate.self,
      OctopusGraphQL.Objects.ClaimFollowupNumber.self,
      OctopusGraphQL.Objects.ClaimFollowupPhoneNumber.self,
      OctopusGraphQL.Objects.ClaimFollowupFileUpload.self
    ]
  )
}