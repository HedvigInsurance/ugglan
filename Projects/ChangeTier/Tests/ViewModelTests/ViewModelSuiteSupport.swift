import TestDependencies
import Testing
import hCore

@testable import ChangeTier

/// Setup and teardown shared by the view model suites: both register DateService, and both have to wait for
/// the view model to go before ChangeTierClient can be removed.
@MainActor
enum ViewModelSuiteSupport {
    static func registerDateService() {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    // Remove the client only after the view model's Task finishes; removing it earlier makes @Inject fatalError.
    static func expectServiceAndViewModelReleased(
        viewModel: @escaping () -> AnyObject?,
        service: () -> AnyObject?,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        await waitUntil(description: "the view model must not outlive the test that created it") {
            viewModel() == nil
        }
        Dependencies.shared.remove(for: ChangeTierClient.self)
        Dependencies.shared.remove(for: DateService.self)
        await delay(0.02)
        #expect(
            service() == nil,
            "the mock service must not outlive its dependency registration",
            sourceLocation: sourceLocation
        )
    }
}
