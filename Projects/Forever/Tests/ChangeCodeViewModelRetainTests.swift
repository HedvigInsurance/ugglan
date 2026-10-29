import Testing
import hCore
import hCoreUI

@testable import Forever

extension ForeverDependencySuite {
    @MainActor
    final class ChangeCodeViewModelRetainTests {
        private weak var sut: MockForeverService?

        @Test
        func inputViewModelCallbacksDoNotRetainOwner() async {
            // Scoped so mockService is released before expectServiceReleased() runs.
            do {
                let mockService = MockData.createMockForeverService()
                sut = mockService
            }

            var owner: ChangeCodeViewModel? = ChangeCodeViewModel(
                input: "code",
                foreverVm: ForeverNavigationViewModel()
            )
            weak let weakOwner = owner

            // Outlives the owner on purpose, as TextInputView's save button keeps it alive mid-request.
            let inputVm: TextInputViewModel = owner!.inputVm

            #expect(inputVm.onSave != nil, "onSave must be installed by init")
            #expect(inputVm.onDismiss != nil, "onDismiss must be installed by init")

            owner = nil

            #expect(weakOwner == nil, "closures stored on inputVm must not keep ChangeCodeViewModel alive")
            withExtendedLifetime(inputVm) {}

            await expectServiceReleased()
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: ForeverClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }
    }
}
