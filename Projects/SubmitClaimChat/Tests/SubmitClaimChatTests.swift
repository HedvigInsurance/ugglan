import Combine
import Foundation
import SwiftUI
import TestDependencies
import Testing
import UIKit
import hCore

@testable import SubmitClaimChat

extension SubmitClaimChatDependencySuite {
    /// Guards the error alerts the screen stores on viewModel.alertVm, hosting the real screen in a window.
    @MainActor
    final class SubmitClaimChatTests {
        // Serialized by the parent suite: both tests share Dependencies.shared and the key window.
        private weak var sut: SubmitClaimChatScreenAlertViewModel?
        private weak var flowSut: SubmitClaimChatViewModel?
        private weak var stepSut: SubmitClaimSingleSelectStep?
        private weak var clientSut: StubClaimIntentClient?

        init() {
            // Zeroes the flow's Timing delays, since the pump advances run-loop turns, not the wall clock.
            disableSubmitChatClaimAnimations = true
            // Mirrors the screen's #Preview DateService registration; Dependencies.resolve fatalErrors without it.
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        }

        private func expectGraphReleased() async {
            Dependencies.shared.remove(for: ClaimIntentClient.self)
            Dependencies.shared.remove(for: DateService.self)
            disableSubmitChatClaimAnimations = false
            await delay(0.0000001)

            #expect(sut == nil, "the alert view model must not outlive the test that hosted the screen")
            #expect(flowSut == nil, "the claim chat view model must not outlive the test that hosted the screen")
            #expect(clientSut == nil, "the stubbed client must not outlive its DI registration")
        }

        /// Flow-start failure: onClose reaching router through the screen would capture the view model.
        @Test
        func startFailureErrorAlertDoesNotRetainFlow() async {
            // Scoped so the client is released before expectGraphReleased(), even when a precondition throws.
            await recordingErrors {
                let scene = try #require(
                    Self.windowScene,
                    "no window scene in this host, so the screen cannot be rendered"
                )
                let client = StubClaimIntentClient(gateStart: true) { throw StubClaimIntentClient.Failure() }
                clientSut = client
                Dependencies.shared.add(module: Module { () -> ClaimIntentClient in client })

                // An async closure, not autoreleasepool (which can't suspend), so every local dies when it returns.
                let storedAlert = try await {
                    [self] () async throws -> SubmitClaimChatScreenAlertViewModel.AlertModel in
                    let viewModel = SubmitClaimChatViewModel(startInput: Self.startInput())
                    flowSut = viewModel
                    sut = viewModel.alertVm
                    // Subscribed before the screen exists, because the stored value is transient.
                    let recorder = AlertRecorder(alertVm: viewModel.alertVm)
                    let stage = Stage(host: Self.host(for: viewModel), scene: scene)
                    // Also runs when a precondition throws, so no root-less key window leaks into later suites.
                    defer { stage.detach() }

                    // .onAppear sets currentVerticalSizeClass, so once it is set the body ran and .onChange is armed.
                    #expect(
                        await pump(until: { viewModel.currentVerticalSizeClass != nil }),
                        "the screen never appeared, so its showError onChange could not observe the failure"
                    )

                    // Start was parked until now, so showError flips false -> true while the screen is hosted.
                    client.releaseStart()

                    #expect(
                        await pump(until: { recorder.model != nil }),
                        "the failed start never reached the screen's showError onChange"
                    )
                    let alertModel = try #require(
                        recorder.model,
                        "precondition: the alert whose closures are under test was never stored on alertVm"
                    )

                    // The detent nils alertModel a turn after storing it; re-store so alertVm owns the closures.
                    viewModel.alertVm.alertModel = alertModel

                    return alertModel
                }()

                await pump(until: { flowSut == nil && sut == nil })

                // storedAlert is deliberately still alive; its closures must hold the view model and router weakly.
                withExtendedLifetime(storedAlert) {
                    #expect(
                        flowSut == nil,
                        "the error alert stored on alertVm must not capture the screen, which holds the view model"
                    )
                    #expect(
                        sut == nil,
                        "the view model owns alertVm, so a captured screen keeps both of them alive"
                    )
                }
            }
            await expectGraphReleased()
        }

        /// Step-submit failure: the alert is built in CurrentStepView.onChange and stored on alertVm.
        @Test
        func stepFailureErrorAlertDoesNotRetainAlertViewModel() async {
            // Scoped for the same reasons as the start-failure test.
            await recordingErrors {
                let scene = try #require(
                    Self.windowScene,
                    "no window scene in this host, so the screen cannot be rendered"
                )
                let intent = Self.singleSelectIntent
                let client = StubClaimIntentClient(gateStart: false) { ClaimIntentType.intent(model: intent) }
                clientSut = client
                Dependencies.shared.add(module: Module { () -> ClaimIntentClient in client })

                let storedAlert = try await {
                    [self] () async throws -> SubmitClaimChatScreenAlertViewModel.AlertModel in
                    let viewModel = SubmitClaimChatViewModel(startInput: Self.startInput())
                    flowSut = viewModel
                    sut = viewModel.alertVm
                    let recorder = AlertRecorder(alertVm: viewModel.alertVm)
                    let stage = Stage(host: Self.host(for: viewModel), scene: scene)
                    defer { stage.detach() }

                    #expect(
                        await pump(until: { (viewModel.currentStep as? SubmitClaimSingleSelectStep) != nil }),
                        "the stubbed start never produced the single-select step the alert is built from"
                    )
                    let step = try #require(viewModel.currentStep as? SubmitClaimSingleSelectStep)
                    stepSut = step

                    // Fixture invariants: without the input shown and a selection, the alert is unreachable.
                    #expect(step.state.showInput, "a step with no message text must show its input immediately")
                    #expect(
                        step.selectedOptionId != nil,
                        "the fixture's defaultSelectedId must give the step a selection"
                    )

                    // Only the GeometryReader behind CurrentStepView writes this, so it proves its onChange is armed.
                    #expect(
                        await pump(until: { viewModel.currentStepInputHeight > 0 }),
                        "the current step input never laid out, so CurrentStepView's onChange is not armed"
                    )

                    step.submitResponse()

                    #expect(
                        await pump(until: { recorder.model != nil }),
                        "the failed submit never reached CurrentStepView's showError onChange"
                    )
                    let alertModel = try #require(
                        recorder.model,
                        "precondition: the alert whose closures are under test was never stored on alertVm"
                    )

                    // Same re-store as the start-failure test: the cycle only closes while alertVm holds the closures.
                    viewModel.alertVm.alertModel = alertModel

                    return alertModel
                }()

                await pump(until: { sut == nil && stepSut == nil })

                withExtendedLifetime(storedAlert) {
                    #expect(
                        sut == nil,
                        "the step's error alert must not capture CurrentStepView, which holds this alert view model"
                    )
                    #expect(stepSut == nil, "a captured CurrentStepView holds its step handler too")
                }
            }
            await expectGraphReleased()
        }

        // MARK: - Fixtures

        private static func startInput() -> SubmitClaimChatInput {
            .init(input: .init(type: .regular(hasInProgress: false)), openChat: {})
        }

        /// No message text, so the input shows immediately and CurrentStepView is on screen.
        private static var singleSelectIntent: ClaimIntent {
            .init(
                currentStep: .init(
                    content: .singleSelect(
                        model: .init(
                            defaultSelectedId: "option1",
                            options: [.init(id: "option1", title: "Option 1")],
                            style: .pill
                        )
                    ),
                    id: "step1",
                    text: nil
                ),
                id: "intent1",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            )
        }

        /// The scene getTopViewController() inspects, so the stage's key window is the presentation target.
        private static var windowScene: UIWindowScene? {
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        }

        /// No navigation stack: it isn't needed for the environment and would add styling and tracking.
        private static func host(for viewModel: SubmitClaimChatViewModel) -> UIViewController {
            UIHostingController(
                rootView:
                    SubmitClaimChatScreen()
                    .environment(viewModel)
                    .environment(viewModel.scrollCoordinator)
                    .environment(viewModel.router)
            )
        }

        // MARK: - Run loop

        /// Bounded by turns rather than a deadline so a failing condition reports instead of hanging.
        @discardableResult
        private func pump(turns: Int = 60, until condition: () -> Bool) async -> Bool {
            for _ in 1...turns {
                if condition() {
                    return true
                }
                // Suspend, not RunLoop.main.run(until:): a nested run loop never runs the flow's main-actor Tasks.
                try? await Task.sleep(for: .seconds(0.01))
            }
            return condition()
        }
    }
}

/// Latches the first stored alert: the detent nils alertModel within the same turn, so polling misses it.
@MainActor
private final class AlertRecorder {
    private(set) var model: SubmitClaimChatScreenAlertViewModel.AlertModel?

    init(alertVm: SubmitClaimChatScreenAlertViewModel) {
        alertVm.onAlertPresentationModelSet = { [weak self] model in
            guard let self, self.model == nil, let model else { return }
            self.model = model
        }
    }
}

/// UIApplication.getWindow() is nil in this example host, so the window is built on the process' scene.
@MainActor
private final class Stage {
    private let window: UIWindow
    private let keyBlocker: UIWindow

    init(host: UIViewController, scene: UIWindowScene) {
        let frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        window = UIWindow(windowScene: scene)
        keyBlocker = UIWindow(windowScene: scene)

        window.frame = frame
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()

        // A key window without a root controller makes .detent present nothing, so no dismissal interferes.
        keyBlocker.frame = frame
        keyBlocker.makeKeyAndVisible()
    }

    /// Releases the SwiftUI graph and removes both windows from the scene before weak refs are read.
    func detach() {
        window.isHidden = true
        window.rootViewController = nil
        keyBlocker.isHidden = true
        window.windowScene = nil
        keyBlocker.windowScene = nil
    }
}

/// Stubs the flow's only service boundary, resolved through @Inject on every call.
@MainActor
private final class StubClaimIntentClient: ClaimIntentClient {
    /// Not a ClaimIntentError: submitResponse swallows .invalidInput without setting state.error.
    struct Failure: Error {}

    private let start: () throws -> ClaimIntentType?
    private var isStartReleased: Bool

    init(gateStart: Bool, start: @escaping () throws -> ClaimIntentType?) {
        self.start = start
        self.isStartReleased = !gateStart
    }

    /// Unparks start; otherwise its failure could land before the screen is hosted and .onChange misses it.
    func releaseStart() {
        isStartReleased = true
    }

    func startClaimIntent(input _: StartClaimInput) async throws -> ClaimIntentType? {
        // Polled, not a continuation, so the pump lets it through; bounded so a failed test can't leak it.
        var turnsLeft = 200
        while !isStartReleased && turnsLeft > 0 {
            turnsLeft -= 1
            try await Task.sleep(for: .seconds(0.005))
        }
        return try start()
    }

    func claimIntentSubmitSelect(stepId _: String, selectedValue _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSubmitAudio(
        fileId _: String?,
        freeText _: String?,
        stepId _: String
    ) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSubmitFile(stepId _: String, fileIds _: [String]) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSubmitForm(fields _: [FieldValue], stepId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSubmitSummary(stepId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSubmitTask(stepId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSubmitInformation(stepId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentSkipStep(stepId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentRegretStep(stepId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func getNextStep(claimIntentId _: String) async throws -> ClaimIntentType? {
        throw Failure()
    }

    func claimIntentFormFieldSearch(
        stepId _: String,
        fieldId _: String,
        query _: String
    ) async throws -> FormFieldSearchResult {
        throw Failure()
    }
}
