// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationSurveyOptionRedirectionFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment TerminationSurveyOptionRedirectionFragment on TerminationFlowSurveyOptionRedirection { __typename title description type actionText image { __typename url overlayText } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOptionRedirection }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("title", String.self),
      .field("description", String.self),
      .field("type", GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionRedirectionType>.self),
      .field("actionText", String.self),
      .field("image", Image?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TerminationSurveyOptionRedirectionFragment.self
    ] }

    ///  Heading of the redirection 
    public var title: String { __data["title"] }
    ///  Body text explaining what the redirection offers 
    public var description: String { __data["description"] }
    ///  Determines which flow the member is redirected to 
    public var type: GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionRedirectionType> { __data["type"] }
    ///  Text for the button that starts the redirection 
    public var actionText: String { __data["actionText"] }
    ///  Optional illustration to show with the redirection 
    public var image: Image? { __data["image"] }

    /// Image
    ///
    /// Parent Type: `TerminationFlowSurveyOptionRedirectionImage`
    nonisolated public struct Image: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOptionRedirectionImage }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("url", String.self),
        .field("overlayText", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationSurveyOptionRedirectionFragment.Image.self
      ] }

      public var url: String { __data["url"] }
      ///  Text to render on top of the image 
      public var overlayText: String? { __data["overlayText"] }
    }
  }

}