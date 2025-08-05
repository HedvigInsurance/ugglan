import hCore

@testable import Claims

@MainActor
struct MockData {
    @discardableResult
    static func createMockFetchClaimService(
        fetch: @escaping FetchClaims = {
            .init(
                claims: [],
                claimsActive: [
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
                ],
                claimsHistory: []
            )
        },
        fetchFiles: @escaping FetchFiles = {
            [:]
        }
    ) -> MockFetchClaimsService {
        let service = MockFetchClaimsService(
            fetch: fetch,
            fetchFiles: fetchFiles
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in service })
        return service
    }
}

enum ClaimsError: Error {
    case error
}

typealias FetchClaims = @Sendable () async throws -> Claims
typealias FetchFiles = () async throws -> [String: [hCore.File]]

class MockFetchClaimsService: hFetchClaimsClient {
    var events = [Event]()
    var fetch: FetchClaims
    var fetchFiles: FetchFiles

    enum Event {
        case get
        case getFiles
    }

    init(
        fetch: @escaping FetchClaims,
        fetchFiles: @escaping FetchFiles
    ) {
        self.fetch = fetch
        self.fetchFiles = fetchFiles
    }

    func get() async throws -> Claims {
        events.append(.get)
        let data = try await fetch()
        return data
    }

    func getFiles() async throws -> [String: [hCore.File]] {
        events.append(.getFiles)
        let data = try await fetchFiles()
        return data
    }
}
