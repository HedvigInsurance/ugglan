// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct IconFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment IconFragment on Icon { __typename variants { __typename light { __typename pdfUrl svgUrl } dark { __typename pdfUrl svgUrl } } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Icon }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("variants", Variants.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      IconFragment.self
    ] }

    public var variants: Variants { __data["variants"] }

    /// Variants
    ///
    /// Parent Type: `IconVariants`
    nonisolated public struct Variants: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.IconVariants }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("light", Light.self),
        .field("dark", Dark.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        IconFragment.Variants.self
      ] }

      public var light: Light { __data["light"] }
      public var dark: Dark { __data["dark"] }

      /// Variants.Light
      ///
      /// Parent Type: `IconVariant`
      nonisolated public struct Light: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.IconVariant }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pdfUrl", String.self),
          .field("svgUrl", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          IconFragment.Variants.Light.self
        ] }

        public var pdfUrl: String { __data["pdfUrl"] }
        public var svgUrl: String { __data["svgUrl"] }
      }

      /// Variants.Dark
      ///
      /// Parent Type: `IconVariant`
      nonisolated public struct Dark: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.IconVariant }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pdfUrl", String.self),
          .field("svgUrl", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          IconFragment.Variants.Dark.self
        ] }

        public var pdfUrl: String { __data["pdfUrl"] }
        public var svgUrl: String { __data["svgUrl"] }
      }
    }
  }

}