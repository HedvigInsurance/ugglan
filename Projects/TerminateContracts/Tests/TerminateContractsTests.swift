import Foundation
import TestDependencies
import Testing
import hCore

@testable import TerminateContracts

extension TerminateContractsDependencySuite {
    @MainActor
    final class TerminateContractsTests {
        private let mockClient = MockTerminateContractsClient()

        init() {
            Dependencies.shared.add(module: Module { [mockClient] () -> TerminateContractsClient in mockClient })
        }

        @Test
        func getTerminationSurveySuccess() async {
            await recordingErrors {
                mockClient.surveyDataToReturn = MockTerminationData.terminateSurveyData
                let service = TerminateContractsService()
                let result = try await service.getTerminationSurvey(contractId: "contract-123")
                #expect(result.options.count == 2)
                #expect(result.options.first?.title == "Better price")
            }

            removeClient()
        }

        @Test
        func getTerminationSurveyError() async {
            do {
                mockClient.errorToThrow = NSError(domain: "test", code: 1)
                let service = TerminateContractsService()
                await #expect(throws: (any Error).self) {
                    try await service.getTerminationSurvey(contractId: "contract-123")
                }
            }

            removeClient()
        }

        @Test
        func terminateContractSuccess() async {
            await recordingErrors {
                mockClient.terminateResultToReturn = .success
                let service = TerminateContractsService()
                let result = try await service.terminateContract(
                    contractId: "contract-123",
                    terminationDate: "2026-04-01",
                    surveyOptionId: "opt1",
                    comment: nil
                )
                #expect(result == .success)
            }

            removeClient()
        }

        @Test
        func terminateContractUserError() async {
            await recordingErrors {
                mockClient.terminateResultToReturn = .userError(message: "Cannot terminate")
                let service = TerminateContractsService()
                let result = try await service.terminateContract(
                    contractId: "contract-123",
                    terminationDate: "2026-04-01",
                    surveyOptionId: "opt1",
                    comment: nil
                )
                #expect(result == .userError(message: "Cannot terminate"))
            }

            removeClient()
        }

        @Test
        func deleteContractSuccess() async {
            await recordingErrors {
                mockClient.deleteResultToReturn = .success
                let service = TerminateContractsService()
                let result = try await service.deleteContract(
                    contractId: "contract-123",
                    surveyOptionId: "opt1",
                    comment: "Goodbye"
                )
                #expect(result == .success)
            }

            removeClient()
        }

        @Test
        func deleteContractUserError() async {
            await recordingErrors {
                mockClient.deleteResultToReturn = .userError(message: "Cannot delete")
                let service = TerminateContractsService()
                let result = try await service.deleteContract(
                    contractId: "contract-123",
                    surveyOptionId: "opt1",
                    comment: nil
                )
                #expect(result == .userError(message: "Cannot delete"))
            }

            removeClient()
        }

        // Runs after the body's scope, so the service that resolved the client is already gone.
        private func removeClient() {
            Dependencies.shared.remove(for: TerminateContractsClient.self)
        }
    }
}
