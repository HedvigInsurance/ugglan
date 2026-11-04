// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFilesQuery: GraphQLQuery {
    public static let operationName: String = "ClaimFiles"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ClaimFiles($claimId: ID!) { claim(id: $claimId) { __typename files { __typename ...FileFragment } } }"#,
        fragments: [FileFragment.self]
      ))

    public var claimId: ID

    public init(claimId: ID) {
      self.claimId = claimId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["claimId": claimId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claim", Claim?.self, arguments: ["id": .variable("claimId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFilesQuery.Data.self
      ] }

      public var claim: Claim? { __data["claim"] }

      /// Claim
      ///
      /// Parent Type: `Claim`
      nonisolated public struct Claim: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Claim }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("files", [File].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFilesQuery.Data.Claim.self
        ] }

        /// A list of all the member-visible, uploaded files for this claim.
        public var files: [File] { __data["files"] }

        /// Claim.File
        ///
        /// Parent Type: `ClaimFile`
        nonisolated public struct File: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFile }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(FileFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFilesQuery.Data.Claim.File.self,
            FileFragment.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          /// The name of the file - usually what the person who uploaded named the file originally.
          public var name: String { __data["name"] }
          /// The mime/media type of the file. See: https://en.wikipedia.org/wiki/Media_type
          public var mimeType: String { __data["mimeType"] }
          /// The URL where the file can be read from.
          ///
          /// Note that these, for security reasons, are signed and somewhat short lived - which means that the the URL might
          /// become invalid for fetching. This can be fixed by simply re-loading the claim.
          public var url: OctopusGraphQL.Url { __data["url"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var fileFragment: FileFragment { _toFragment() }
          }
        }
      }
    }
  }

}