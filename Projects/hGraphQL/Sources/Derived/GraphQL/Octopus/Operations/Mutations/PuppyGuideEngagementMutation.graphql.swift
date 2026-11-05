// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PuppyGuideEngagementMutation: GraphQLMutation {
    public static let operationName: String = "PuppyGuideEngagement"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PuppyGuideEngagement($name: String!, $rating: Int, $read: Boolean) { puppyGuideEngagement(engagement: { name: $name, rating: $rating, read: $read }) { __typename success } }"#
      ))

    public var name: String
    public var rating: GraphQLNullable<Int32>
    public var read: GraphQLNullable<Bool>

    public init(
      name: String,
      rating: GraphQLNullable<Int32>,
      read: GraphQLNullable<Bool>
    ) {
      self.name = name
      self.rating = rating
      self.read = read
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "name": name,
      "rating": rating,
      "read": read
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("puppyGuideEngagement", PuppyGuideEngagement.self, arguments: ["engagement": [
          "name": .variable("name"),
          "rating": .variable("rating"),
          "read": .variable("read")
        ]]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PuppyGuideEngagementMutation.Data.self
      ] }

      /// Mark a young pet guide story as read for a specific member.
      public var puppyGuideEngagement: PuppyGuideEngagement { __data["puppyGuideEngagement"] }

      /// PuppyGuideEngagement
      ///
      /// Parent Type: `PuppyGuideStoryMutationOutput`
      nonisolated public struct PuppyGuideEngagement: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PuppyGuideStoryMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PuppyGuideEngagementMutation.Data.PuppyGuideEngagement.self
        ] }

        /// Indicates whether the mutation was successful.
        public var success: Bool { __data["success"] }
      }
    }
  }

}