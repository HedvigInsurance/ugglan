import Foundation
import TestDependencies
import Testing
import hCore

@testable import TerminateContractsCore

extension TerminateContractsDependencySuite {
    @MainActor
    final class ContractWithdrawalServiceTests {
        private weak var sut: MockTerminateContractsClient?

        @Test
        func getContractWithdrawalSuccess() async {
            await recordingErrors {
                let expected = ContractWithdrawalData(
                    statusText: "Active since 2026-11-20",
                    action: .terminateWithDate(minDate: "2026-11-20", maxDate: "2026-11-20", extraCoverage: []),
                    email: "member@hedvig.com"
                )
                let mockClient = registerMockClient()
                mockClient.withdrawalDataToReturn = expected

                let result = try await TerminateContractsService().getContractWithdrawal(contractId: "contract-123")

                #expect(result == expected)
                #expect(mockClient.events == [.getContractWithdrawal(contractId: "contract-123")])
            }

            await expectClientReleased()
        }

        @Test
        func getContractWithdrawalError() async {
            do {
                let mockClient = registerMockClient()
                mockClient.errorToThrow = NSError(domain: "test", code: 1)

                await #expect(throws: (any Error).self) {
                    try await TerminateContractsService().getContractWithdrawal(contractId: "contract-123")
                }
                #expect(mockClient.events == [.getContractWithdrawal(contractId: "contract-123")])
            }

            await expectClientReleased()
        }

        @Test
        func withdrawContractSuccess() async {
            await recordingErrors {
                let mockClient = registerMockClient()
                mockClient.withdrawResultToReturn = .success

                let start = ContinuousClock.now
                let result = try await TerminateContractsService().withdrawContract(contractId: "contract-123")
                let elapsed = ContinuousClock.now - start

                #expect(result == .success)
                #expect(mockClient.events == [.withdrawContract(contractId: "contract-123")])
                // Same minimum duration as terminate/delete, so the processing screen doesn't flash.
                #expect(elapsed >= .seconds(3))
            }

            await expectClientReleased()
        }

        @Test
        func withdrawContractUserError() async {
            await recordingErrors {
                let mockClient = registerMockClient()
                mockClient.withdrawResultToReturn = .userError(message: "Withdrawal period has passed")

                let result = try await TerminateContractsService().withdrawContract(contractId: "contract-123")

                #expect(result == .userError(message: "Withdrawal period has passed"))
                #expect(mockClient.events == [.withdrawContract(contractId: "contract-123")])
            }

            await expectClientReleased()
        }

        @Test
        func withdrawContractError() async {
            do {
                let mockClient = registerMockClient()
                mockClient.errorToThrow = NSError(domain: "test", code: 1)

                await #expect(throws: (any Error).self) {
                    try await TerminateContractsService().withdrawContract(contractId: "contract-123")
                }
                #expect(mockClient.events == [.withdrawContract(contractId: "contract-123")])
            }

            await expectClientReleased()
        }

        private func registerMockClient() -> MockTerminateContractsClient {
            let mockClient = MockTerminateContractsClient()
            sut = mockClient
            Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
            return mockClient
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectClientReleased() async {
            Dependencies.shared.remove(for: TerminateContractsClient.self)
            await delay(0.00001)
            #expect(sut == nil, "the mock client must not outlive the test that created it")
        }
    }
}
