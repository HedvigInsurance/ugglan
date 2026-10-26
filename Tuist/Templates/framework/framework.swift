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

// Matches most existing Example apps, which ship only an app delegate. Project.framework's scene manifest names
// <Name>Example.SceneDelegate; add one (see Projects/Claims/Example) if the example needs to show a window.
let appDelegateContents = """
    import UIKit

    @main class AppDelegate: UIResponder, UIApplicationDelegate {
        var window: UIWindow?

        func application(
            _: UIApplication,
            didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            true
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

let xcassetsContents = """
    {
      "info" : {
        "version" : 1,
        "author" : "xcode"
      }
    }

    """

let xcassetsAppIconContents = """
    {
      "images" : [
        {
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "20x20"
        },
        {
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "20x20"
        },
        {
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "29x29"
        },
        {
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "29x29"
        },
        {
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "40x40"
        },
        {
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "40x40"
        },
        {
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "60x60"
        },
        {
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "60x60"
        },
        {
          "idiom" : "ipad",
          "scale" : "1x",
          "size" : "20x20"
        },
        {
          "idiom" : "ipad",
          "scale" : "2x",
          "size" : "20x20"
        },
        {
          "idiom" : "ipad",
          "scale" : "1x",
          "size" : "29x29"
        },
        {
          "idiom" : "ipad",
          "scale" : "2x",
          "size" : "29x29"
        },
        {
          "idiom" : "ipad",
          "scale" : "1x",
          "size" : "40x40"
        },
        {
          "idiom" : "ipad",
          "scale" : "2x",
          "size" : "40x40"
        },
        {
          "idiom" : "ipad",
          "scale" : "1x",
          "size" : "76x76"
        },
        {
          "idiom" : "ipad",
          "scale" : "2x",
          "size" : "76x76"
        },
        {
          "idiom" : "ipad",
          "scale" : "2x",
          "size" : "83.5x83.5"
        },
        {
          "idiom" : "ios-marketing",
          "scale" : "1x",
          "size" : "1024x1024"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }

    """

let template = Template(
    description: "Framework template",
    attributes: [nameAttribute, .optional("platform", default: "iOS")],
    items: [
        .string(path: "\(nameAttribute)/Example/Sources/AppDelegate.swift", contents: appDelegateContents),
        .string(
            path: "\(nameAttribute)/Example/Resources/Assets.xcassets/Contents.json",
            contents: xcassetsContents
        ),
        .string(
            path: "\(nameAttribute)/Example/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json",
            contents: xcassetsAppIconContents
        ),
        .string(path: "\(nameAttribute)/GraphQL/ExampleQuery.graphql", contents: graphqlExampleQueryContents),
        .string(path: "\(nameAttribute)/Sources/\(nameAttribute).swift", contents: exampleContents),
        .string(path: "\(nameAttribute)/Tests/\(nameAttribute)Tests.swift", contents: testContents),
        .file(path: "\(nameAttribute)/Project.swift", templatePath: "project.stencil"),
    ]
)
