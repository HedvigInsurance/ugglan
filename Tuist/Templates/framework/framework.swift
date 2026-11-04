import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let exampleContents = """
    import Foundation

    struct \(nameAttribute) { }

    """

let testContents = """
    import Testing

    @testable import \(nameAttribute)

    @MainActor
    final class \(nameAttribute)Tests {

        init() {
            // Swift Testing builds a fresh instance per test, so this replaces setUp
        }

        @Test func example() {
            // Add your test here
        }

    }

    """

let graphqlExampleQueryContents = """
    query Example {
        member {
            id
        }
    }

    """

let template = Template(
    description: "Framework template",
    attributes: [nameAttribute, .optional("platform", default: "iOS")],
    items: [
        .string(path: "\(nameAttribute)/GraphQL/ExampleQuery.graphql", contents: graphqlExampleQueryContents),
        .string(path: "\(nameAttribute)/Sources/\(nameAttribute).swift", contents: exampleContents),
        .string(path: "\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", contents: testContents),
        .file(path: "\(nameAttribute)/Project.swift", templatePath: "project.stencil"),
    ]
)
