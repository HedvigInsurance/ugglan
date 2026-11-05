// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Unions {
  /// A union of all the different kinds of "step content".
  nonisolated static let ClaimIntentStepContent = Union(
    name: "ClaimIntentStepContent",
    possibleTypes: [
      OctopusGraphQL.Objects.ClaimIntentStepContentForm.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentSelect.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentTask.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentAudioRecording.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentFileUpload.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentSummary.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentDeflection.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionMessage.self,
      OctopusGraphQL.Objects.ClaimIntentStepContentInformation.self
    ]
  )
}