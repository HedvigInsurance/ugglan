import XCTest

@testable import SubmitClaimChat

private final class AlertClosureProbe {}

@MainActor
final class SubmitClaimChatAlertViewModelRetainTests: XCTestCase {
    weak var sut: SubmitClaimChatScreenAlertViewModel?

    override func tearDown() async throws {
        try await super.tearDown()

        XCTAssertNil(sut, "SubmitClaimChatScreenAlertViewModel must not outlive the test that created it")
    }

    func testErrorAlertDismissalReleasesClosures() {
        let viewModel = SubmitClaimChatScreenAlertViewModel()
        sut = viewModel

        weak var probe: AlertClosureProbe?
        // Built in its own scope so the closures stored on the view model end up the probe's only
        // owner; a strong reference left in this frame would hide a leak from the assertions below.
        do {
            let strongProbe = AlertClosureProbe()
            probe = strongProbe
            viewModel.alertModel = .init(
                type: .error,
                message: "message",
                action: { _ = strongProbe },
                onClose: { _ = strongProbe }
            )
        }

        XCTAssertNotNil(
            viewModel.alertPresentationModel,
            "an .error alert must be routed into alertPresentationModel, otherwise nothing below is exercised"
        )
        XCTAssertNotNil(probe, "the stored alert closures must hold the probe while the alert is presented")

        viewModel.alertPresentationModel = nil

        XCTAssertNil(probe, "dismissing the presented alert must clear alertModel and release its closures")
    }

    func testEditAlertPerformActionReleasesClosures() {
        let viewModel = SubmitClaimChatScreenAlertViewModel()
        sut = viewModel

        var actionRan = false
        weak var probe: AlertClosureProbe?
        // Same scoping as above: only the model's own closures may own the probe.
        do {
            let strongProbe = AlertClosureProbe()
            probe = strongProbe
            viewModel.alertModel = .init(
                type: .edit,
                message: "message",
                action: {
                    actionRan = true
                    _ = strongProbe
                },
                onClose: { _ = strongProbe }
            )
        }

        XCTAssertNotNil(probe, "both alert closures must hold the probe before the alert is answered")

        viewModel.performAction()

        XCTAssertTrue(actionRan, "performAction must run the alert's action closure")
        XCTAssertNil(probe, "performAction must clear alertModel and release both of its closures")
    }

    func testEditAlertPerformCloseReleasesClosures() {
        let viewModel = SubmitClaimChatScreenAlertViewModel()
        sut = viewModel

        var closeRan = false
        weak var probe: AlertClosureProbe?
        // Same scoping as above: only the model's own closures may own the probe.
        do {
            let strongProbe = AlertClosureProbe()
            probe = strongProbe
            viewModel.alertModel = .init(
                type: .edit,
                message: "message",
                action: { _ = strongProbe },
                onClose: {
                    closeRan = true
                    _ = strongProbe
                }
            )
        }

        XCTAssertNotNil(probe, "both alert closures must hold the probe before the alert is dismissed")

        viewModel.performClose()

        XCTAssertTrue(closeRan, "performClose must run the alert's onClose closure")
        XCTAssertNil(probe, "performClose must clear alertModel and release both of its closures")
    }
}
