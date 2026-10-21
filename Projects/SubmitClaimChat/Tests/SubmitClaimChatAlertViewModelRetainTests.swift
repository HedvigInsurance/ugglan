import Testing

@testable import SubmitClaimChat

private final class AlertClosureProbe {}

@MainActor
final class SubmitClaimChatAlertViewModelRetainTests {
    private weak var sut: SubmitClaimChatScreenAlertViewModel?

    @Test
    func errorAlertDismissalReleasesClosures() {
        // Scoped so viewModel is released before expectAlertViewModelReleased() runs.
        do {
            let viewModel = SubmitClaimChatScreenAlertViewModel()
            sut = viewModel

            weak var probe: AlertClosureProbe?
            // Own scope so the view model's closures are the probe's only owner; a local ref would hide a leak.
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

            #expect(
                viewModel.alertPresentationModel != nil,
                "an .error alert must be routed into alertPresentationModel, otherwise nothing below is exercised"
            )
            #expect(probe != nil, "the stored alert closures must hold the probe while the alert is presented")

            viewModel.alertPresentationModel = nil

            #expect(probe == nil, "dismissing the presented alert must clear alertModel and release its closures")
        }

        expectAlertViewModelReleased()
    }

    @Test
    func editAlertPerformActionReleasesClosures() {
        do {
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

            #expect(probe != nil, "both alert closures must hold the probe before the alert is answered")

            viewModel.performAction()

            #expect(actionRan, "performAction must run the alert's action closure")
            #expect(probe == nil, "performAction must clear alertModel and release both of its closures")
        }

        expectAlertViewModelReleased()
    }

    @Test
    func editAlertPerformCloseReleasesClosures() {
        do {
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

            #expect(probe != nil, "both alert closures must hold the probe before the alert is dismissed")

            viewModel.performClose()

            #expect(closeRan, "performClose must run the alert's onClose closure")
            #expect(probe == nil, "performClose must clear alertModel and release both of its closures")
        }

        expectAlertViewModelReleased()
    }

    private func expectAlertViewModelReleased() {
        #expect(sut == nil, "SubmitClaimChatScreenAlertViewModel must not outlive the test that created it")
    }
}
