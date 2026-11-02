import SwiftUI
import Testing
import hCore
import hCoreUI

@testable import SubmitClaimChat

extension SubmitClaimChatDependencySuite {
    /// Uses ImageRenderer: the repo's SnapshotTesting helpers can't be imported from a .tests target.
    final class SubmitClaimSummaryViewSnapshotTests {
        // Serialized by the parent suite: both tests register DateService in Dependencies.shared and each makes its
        // own UIWindow key, so running them alongside other suites would race for the key window.
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
        private func render<V: View>(_ view: V, name: String, height: CGFloat) async throws -> URL {
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
            // Suspend instead of spinning the run loop, so main-actor Tasks (e.g. `.task`) get to run before drawing.
            try? await Task.sleep(for: .seconds(1))

            let format = UIGraphicsImageRendererFormat()
            format.scale = 2
            let image = UIGraphicsImageRenderer(bounds: bounds, format: format)
                .image { _ in
                    hostingController.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
                }
            let data = try #require(image.pngData(), "PNG encoding failed for \(name)")

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

        @Test
        @MainActor
        func collapsedClaimDetailsCard() async throws {
            registerDependencies()
            let step = makeStep()
            let url = try await render(
                hForm {
                    hSection {
                        SubmitClaimSummaryView(viewModel: step)
                    }
                },
                name: "collapsed_claim_details_card",
                height: 640
            )
            #expect(FileManager.default.fileExists(atPath: url.path))
        }

        @Test
        @MainActor
        func showAllAnswersContent() async throws {
            registerDependencies()
            let step = makeStep()
            let url = try await render(
                SubmitClaimSummaryAnswersView(answers: summaryModel.answers, audioPlayers: step.audioPlayers)
                    .navigationTitle(L10n.ClaimStatus.ClaimDetails.title)
                    .embededInNavigation(tracking: String(describing: SubmitClaimSummaryAnswersView.self)),
                name: "show_all_answers_content",
                height: 720
            )
            #expect(FileManager.default.fileExists(atPath: url.path))
        }
    }
}
