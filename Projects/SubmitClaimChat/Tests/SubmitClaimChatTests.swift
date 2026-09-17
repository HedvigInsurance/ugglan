import Combine
import Foundation
import SwiftUI
import UIKit
@preconcurrency import XCTest
import hCore

@testable import SubmitClaimChat

/// Guards the error alerts the claim chat screen builds inside its `.onChange` modifiers and stores
/// on `viewModel.alertVm`. Those closures are written in the view layer, so both tests host the real
/// `SubmitClaimChatScreen` in a window. Neither test answers or closes the alert: the stored model,
/// and whatever it captured, is what the screen leaves behind when it goes away, which is exactly
/// the moment a captured view keeps the flow alive.
@MainActor
final class SubmitClaimChatTests: XCTestCase {
    weak var sut: SubmitClaimChatScreenAlertViewModel?
    weak var flowSut: SubmitClaimChatViewModel?
    weak var stepSut: SubmitClaimSingleSelectStep?
    private weak var clientSut: StubClaimIntentClient?

    override func setUp() async throws {
        try await super.setUp()

        // Collapses every ClaimChatConstants.Timing delay to zero: the flow reaches its step
        // through sleeps, and the pump below advances run-loop turns, not the wall clock.
        disableSubmitChatClaimAnimations = true
        // `Dependencies.resolve` fatalErrors on a missing registration, so the screen's own
        // #Preview registration is mirrored for anything in the rendered tree that formats a date.
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ClaimIntentClient.self)
        Dependencies.shared.remove(for: DateService.self)
        disableSubmitChatClaimAnimations = false
        await delay(0.0000001)

        XCTAssertNil(sut, "the alert view model must not outlive the test that hosted the screen")
        XCTAssertNil(flowSut, "the claim chat view model must not outlive the test that hosted the screen")
        XCTAssertNil(clientSut, "the stubbed client must not outlive its DI registration")

        try await super.tearDown()
    }

    /// The flow-start failure: `SubmitClaimChatViewModel.init` kicks off `startClaimIntent()`, the
    /// service throws, and the screen's own `.onChange(of: viewModel.showError)` builds the alert.
    /// Its `onClose` runs on `router`, which the screen reads from the environment - reaching it
    /// through the screen struct captures `@EnvironmentObject var viewModel` with it, and the view
    /// model owns the `alertVm` the closure is stored on.
    func testStartFailureErrorAlertDoesNotRetainFlow() throws {
        let scene = try XCTUnwrap(Self.windowScene, "no window scene in this host, so the screen cannot be rendered")
        let client = StubClaimIntentClient(gateStart: true) { throw StubClaimIntentClient.Failure() }
        clientSut = client
        Dependencies.shared.add(module: Module { () -> ClaimIntentClient in client })

        let storedAlert = try autoreleasepool { () throws -> SubmitClaimChatScreenAlertViewModel.AlertModel in
            let viewModel = SubmitClaimChatViewModel(startInput: Self.startInput())
            flowSut = viewModel
            sut = viewModel.alertVm
            // Subscribed before the screen exists, because the stored value is transient.
            let recorder = AlertRecorder(alertVm: viewModel.alertVm)
            let stage = Stage(host: Self.host(for: viewModel), scene: scene)
            // Runs after the re-store below, and also when a precondition throws, so a failed test
            // cannot leave a root-less key window behind for the suites that follow.
            defer { stage.detach() }

            // `.onChange` only reports a change the screen was rendered for, and the screen's own
            // `.onAppear` is what writes `currentVerticalSizeClass`: once that is set, the body has
            // been evaluated with `showError == false` and the modifier is armed.
            XCTAssertTrue(
                pump(until: { viewModel.currentVerticalSizeClass != nil }),
                "the screen never appeared, so its showError onChange could not observe the failure"
            )

            // The start call has been parked in the stub until now, so the false -> true transition
            // of showError is guaranteed to happen while the screen is hosted.
            client.releaseStart()

            XCTAssertTrue(
                pump(until: { recorder.model != nil }),
                "the failed start never reached the screen's showError onChange"
            )
            let alertModel = try XCTUnwrap(
                recorder.model,
                "precondition: the alert whose closures are under test was never stored on alertVm"
            )

            // The screen's own detent nils `alertModel` again a run-loop turn after it is stored
            // (DetentRouter.swift:171-175 -> :85-89, AlertHelper.swift:19-25), so the recorded
            // value goes back: the closures have to be owned by alertVm, the way they are while
            // the alert is on screen, when the graph is released below.
            viewModel.alertVm.alertModel = alertModel

            return alertModel
        }

        pump(until: { flowSut == nil && sut == nil })

        // The recorded alert is deliberately still alive here: on the fixed tree its closures hold
        // the view model and the router weakly, so nothing below can be kept alive through them.
        withExtendedLifetime(storedAlert) {
            XCTAssertNil(
                flowSut,
                "the error alert stored on alertVm must not capture the screen, which holds the view model"
            )
            XCTAssertNil(sut, "the view model owns alertVm, so a captured screen keeps both of them alive")
        }
    }

    /// The step-submit failure: the alert is built in `CurrentStepView.onChange(of:
    /// step.state.showError)` and stored on the `alertVm` that same view reads from the environment.
    /// A closure that reaches `step` or `router` through the view captures the view, and with it the
    /// alert view model that owns the closure.
    func testStepFailureErrorAlertDoesNotRetainAlertViewModel() throws {
        let scene = try XCTUnwrap(Self.windowScene, "no window scene in this host, so the screen cannot be rendered")
        let intent = Self.singleSelectIntent
        let client = StubClaimIntentClient(gateStart: false) { ClaimIntentType.intent(model: intent) }
        clientSut = client
        Dependencies.shared.add(module: Module { () -> ClaimIntentClient in client })

        let storedAlert = try autoreleasepool { () throws -> SubmitClaimChatScreenAlertViewModel.AlertModel in
            let viewModel = SubmitClaimChatViewModel(startInput: Self.startInput())
            flowSut = viewModel
            sut = viewModel.alertVm
            let recorder = AlertRecorder(alertVm: viewModel.alertVm)
            let stage = Stage(host: Self.host(for: viewModel), scene: scene)
            defer { stage.detach() }

            XCTAssertTrue(
                pump(until: { (viewModel.currentStep as? SubmitClaimSingleSelectStep) != nil }),
                "the stubbed start never produced the single-select step the alert is built from"
            )
            let step = try XCTUnwrap(viewModel.currentStep as? SubmitClaimSingleSelectStep)
            stepSut = step

            // Fixture invariants rather than arming proofs, but the alert is unreachable without
            // them: CurrentStepView renders nothing while showInput is false, and with no selection
            // executeStep throws .invalidInput, which submitResponse swallows without an error.
            XCTAssertTrue(step.state.showInput, "a step with no message text must show its input immediately")
            XCTAssertNotNil(step.selectedOptionId, "the fixture's defaultSelectedId must give the step a selection")

            // Written only by the GeometryReader behind CurrentStepView, so a height is what proves
            // that view was laid out - and its onChange armed - before the submit flips showError.
            XCTAssertTrue(
                pump(until: { viewModel.currentStepInputHeight > 0 }),
                "the current step input never laid out, so CurrentStepView's onChange is not armed"
            )

            step.submitResponse()

            XCTAssertTrue(
                pump(until: { recorder.model != nil }),
                "the failed submit never reached CurrentStepView's showError onChange"
            )
            let alertModel = try XCTUnwrap(
                recorder.model,
                "precondition: the alert whose closures are under test was never stored on alertVm"
            )

            // Same re-store as the start-failure test: the detent drops the model on its own, and
            // the cycle under test only closes while alertVm is the one holding these closures.
            viewModel.alertVm.alertModel = alertModel

            return alertModel
        }

        pump(until: { sut == nil && stepSut == nil })

        withExtendedLifetime(storedAlert) {
            XCTAssertNil(
                sut,
                "the step's error alert must not capture CurrentStepView, which holds this alert view model"
            )
            XCTAssertNil(stepSut, "a captured CurrentStepView holds its @ObservedObject step handler too")
        }
    }

    // MARK: - Fixtures

    private static func startInput() -> SubmitClaimChatInput {
        .init(input: .init(type: .regular(hasInProgress: false)), openChat: {})
    }

    /// One single-select step with no message text: `ClaimIntentStepHandler.init` shows the input
    /// immediately when there is no text to reveal, which is what puts `CurrentStepView` on screen.
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

    /// The same scene `UIApplication.getTopViewController()` inspects, so the key window the stage
    /// puts up is the one the alert's detent asks for a presentation target.
    private static var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    /// The environment the screen declares: the view model, its scroll coordinator and the router.
    /// In production all three come from `SubmitClaimFlowNavigation`, which hands `viewModel.router`
    /// to `hNavigationStack` and lets that inject it, so the router the screen resolves is the view
    /// model's own. No navigation stack is added here: it is not needed to resolve the environment
    /// object, and it would drag navigation-bar styling and view tracking into the measurement.
    private static func host(for viewModel: SubmitClaimChatViewModel) -> UIViewController {
        UIHostingController(
            rootView:
                SubmitClaimChatScreen()
                .environmentObject(viewModel)
                .environmentObject(viewModel.scrollCoordinator)
                .environmentObject(viewModel.router)
        )
    }

    // MARK: - Run loop

    /// Bounded run-loop pump: a turn is a main-queue hop the XCTest waiter spins the run loop for,
    /// which drains task continuations and lets SwiftUI commit a render pass between checks. Bounded
    /// by turns rather than a deadline so a failing condition reports instead of hanging.
    @discardableResult
    private func pump(turns: Int = 60, until condition: () -> Bool) -> Bool {
        for turn in 1...turns {
            if condition() {
                return true
            }
            let pumped = expectation(description: "run loop turn \(turn)")
            RunLoop.main.perform { pumped.fulfill() }
            wait(for: [pumped], timeout: 1)
            // A queue hop alone can spin faster than the timers the flow is waiting on, so each turn
            // also hands the run loop a slice of real time.
            RunLoop.current.run(until: Date() + 0.01)
        }
        return condition()
    }
}

/// Latches the first alert the screen stores. Polling `alertVm.alertModel` would not see it: the
/// `.detent` in `SubmitClaimChatScreenAlertHelper` presents nothing while the stage's root-less
/// window is key, so its throwaway `hHostingController` deinits at once and writes `presented =
/// false` back, nilling `alertPresentationModel` and with it `alertModel` - usually inside the same
/// run-loop turn that stored it. `@Published` emits in `willSet`, so the store itself cannot be
/// missed.
@MainActor
private final class AlertRecorder {
    private(set) var model: SubmitClaimChatScreenAlertViewModel.AlertModel?
    private var cancellable: AnyCancellable?

    init(alertVm: SubmitClaimChatScreenAlertViewModel) {
        cancellable = alertVm.$alertPresentationModel
            .sink { [weak self] model in
                guard let self, self.model == nil, let model else { return }
                self.model = model
            }
    }
}

/// The window the screen is rendered in. `UIApplication.getWindow()` is nil in this example host, so
/// the window is built against the process' scene here.
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

        // The error alert also presents through `.detent`, which asks
        // `UIApplication.getTopViewController()` for a target - a key window without a root
        // controller answers nil, so nothing is presented. The alert model is still built and
        // stored, which is the state under test, but no presented alert content ends up owning the
        // alert view model, and no UIKit dismissal decides the result behind the test's back.
        keyBlocker.frame = frame
        keyBlocker.makeKeyAndVisible()
    }

    /// Tears the screen down the way a dismissal does, releasing the SwiftUI graph and every closure
    /// it captured before the weak references are read. Both windows also leave the scene, so no
    /// later suite inherits a key window with no root view controller.
    func detach() {
        window.isHidden = true
        window.rootViewController = nil
        keyBlocker.isHidden = true
        window.windowScene = nil
        keyBlocker.windowScene = nil
    }
}

/// Stubs the flow at its only service boundary. `ClaimIntentService` resolves this through `@Inject`
/// on every call, so nothing else has to be faked.
@MainActor
private final class StubClaimIntentClient: ClaimIntentClient {
    /// Deliberately not a `ClaimIntentError`: `ClaimIntentStepHandler.submitResponse` swallows
    /// `.invalidInput` without ever setting `state.error`, and the alert is only built from one.
    struct Failure: Error {}

    private let start: () throws -> ClaimIntentType?
    private var isStartReleased: Bool

    init(gateStart: Bool, start: @escaping () throws -> ClaimIntentType?) {
        self.start = start
        self.isStartReleased = !gateStart
    }

    /// Lets a parked start call finish. `SubmitClaimChatViewModel.init` fires `startClaimIntent()`
    /// straight away, so without the gate its failure could land before the screen is in the window,
    /// where the screen's `.onChange` would never see the transition.
    func releaseStart() {
        isStartReleased = true
    }

    func startClaimIntent(input _: StartClaimInput) async throws -> ClaimIntentType? {
        // Parked by polling rather than a continuation: the call is suspended on the main actor the
        // test is pumping, so a turn of the pump is what lets it through. Bounded, so a test that
        // fails before releaseStart() cannot leave a task holding the flow for the whole process.
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
