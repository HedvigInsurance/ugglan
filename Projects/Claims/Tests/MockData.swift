import hCore

@testable import Claims

@MainActor
struct MockData {
    @discardableResult
    static func createMockFetchClaimService(
        fetchActive: @escaping FetchClaims = {
            [
                .init(
                    id: "id",
                    status: .beingHandled,
                    outcome: .none,
                    submittedAt: nil,
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "",
                    productVariant: nil,
                    conversation: nil,
                    appealInstructionsUrl: nil,
                    isUploadingFilesEnabled: false,
                    showClaimClosedFlow: false,
                    infoText: nil,
                    displayItems: []
                )
            ]
        },
        fetchHistory: @escaping FetchClaims = {
            [
                .init(
                    id: "id2",
                    status: .closed,
                    outcome: .none,
                    submittedAt: nil,
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "",
                    productVariant: nil,
                    conversation: nil,
                    appealInstructionsUrl: nil,
                    isUploadingFilesEnabled: false,
                    showClaimClosedFlow: false,
                    infoText: nil,
                    displayItems: []
                )
            ]
        },
        fetchFiles: @escaping FetchFiles = {
            [:]
        }
    ) -> MockFetchClaimsService {
        let service = MockFetchClaimsService(
            fetchActive: fetchActive,
            fetchHistory: fetchHistory,
            fetchFiles: fetchFiles
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in service })
        return service
    }
}

enum ClaimsError: Error {
    case error
}

typealias FetchClaims = @Sendable () async throws -> [ClaimModel]
typealias FetchFiles = () async throws -> [String: [hCore.File]]

class MockFetchClaimsService: hFetchClaimsClient {
    var events = [Event]()
    var fetchActive: FetchClaims
    var fetchHistory: FetchClaims
    var fetchFiles: FetchFiles

    enum Event {
        case getActive
        case getHistory
        case getFiles
    }

    init(
        fetchActive: @escaping FetchClaims,
        fetchHistory: @escaping FetchClaims,
        fetchFiles: @escaping FetchFiles
    ) {
        self.fetchActive = fetchActive
        self.fetchHistory = fetchHistory
        self.fetchFiles = fetchFiles
    }

    func getActiveClaims() async throws -> [ClaimModel] {
        events.append(.getActive)
        let data = try await fetchActive()
        return data
    }

    func getHistoryClaims() async throws -> [Claims.ClaimModel] {
        events.append(.getHistory)
        let data = try await fetchHistory()
        return data
    }

    func getFiles() async throws -> [String: [hCore.File]] {
        events.append(.getFiles)
        let data = try await fetchFiles()
        return data
    }
}
