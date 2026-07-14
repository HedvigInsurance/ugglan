import SwiftUI
import XCTest
import hCore
import hCoreUI

@testable import SubmitClaimChat

/// Renders the redesigned claim summary surfaces to PNGs so the collapsed
/// "Claim details" card, a text answer and an inline audio player can be
/// visually verified.
///
/// NOTE: the repo's `SnapshotTesting`/`assertSnapshot` helpers are vended by the
/// `HedvigShared` (umbrella) package. In the current binary-umbrella
/// configuration that module is not importable from a `.tests` target (the
/// existing `*/Testing` snapshot folders are not wired into any Tuist target),
/// so this uses SwiftUI `ImageRenderer` directly instead.
final class SubmitClaimSummaryViewSnapshotTests: XCTestCase {
    @MainActor
    private func registerDependencies() {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    private var summaryModel: ClaimIntentStepContentSummary {
        .init(
            audioRecordings: [
                .init(url: URL(string: "https://hedvig.com/recording.m4a")!)
            ],
            fileUploads: [],
            items: [
                .init(title: "Date", value: "2025-11-25"),
                .init(title: "Location", value: "At home"),
            ],
            freeTexts: [],
            keyDetails: [
                .init(title: "Type of claim", value: "Theft"),
                .init(title: "Date", value: "2025-11-25"),
                .init(title: "Location", value: "Stockholm"),
            ],
            answers: [
                .init(title: "Was the bike locked?", value: .text("No")),
                .init(
                    title: "Where did it happen?",
                    value: .text("Outside the central station in Stockholm")
                ),
                .init(
                    title: "Describe what happened",
                    value: .audio(
                        url: URL(string: "https://hedvig.com/recording.m4a")!,
                        transcript: "I parked my bike and when I came back it was gone."
                    )
                ),
                .init(
                    title: "Any receipts?",
                    value: .files([
                        .init(
                            url: URL(string: "https://hedvig.com/receipt.pdf")!,
                            contentType: .PDF,
                            fileName: "receipt.pdf"
                        )
                    ])
                ),
            ]
        )
    }

    @MainActor
    private func makeStep() -> SubmitClaimSummaryStep {
        SubmitClaimSummaryStep(
            claimIntent: .init(
                currentStep: .init(
                    content: .summary(model: summaryModel),
                    id: "id1",
                    text: "text"
                ),
                id: "claimIntentId",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            ),
            service: .init(),
            mainHandler: { _ in }
        )
    }

    @MainActor
    private func render<V: View>(_ view: V, name: String, height: CGFloat) throws -> URL {
        let bounds = CGRect(x: 0, y: 0, width: 390, height: height)
        let hostingController = UIHostingController(
            rootView:
                view
                .frame(width: bounds.width, height: bounds.height, alignment: .top)
                .background(Color.white)
                .environment(\.colorScheme, .light)
        )
        let window = UIWindow(frame: bounds)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.frame = bounds
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(1.0))

        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        let image = UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
            hostingController.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        let data = try XCTUnwrap(image.pngData(), "PNG encoding failed for \(name)")

        let dir =
            ProcessInfo.processInfo.environment["SNAPSHOT_ARTIFACTS"]
            .map { URL(fileURLWithPath: $0) }
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("SubmitClaimSummarySnapshots", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("\(name).png")
        try data.write(to: url)
        print("SNAPSHOT_PNG \(name) -> \(url.path)")
        return url
    }

    @MainActor
    func testCollapsedClaimDetailsCard() throws {
        registerDependencies()
        let step = makeStep()
        let url = try render(
            hForm {
                hSection {
                    SubmitClaimSummaryView(viewModel: step)
                }
            },
            name: "collapsed_claim_details_card",
            height: 640
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    @MainActor
    func testShowAllAnswersContent() throws {
        registerDependencies()
        let url = try render(
            SubmitClaimSummaryAnswersView(answers: summaryModel.answers),
            name: "show_all_answers_content",
            height: 720
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
