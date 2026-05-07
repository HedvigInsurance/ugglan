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

typealias FetchClaimDetail = @Sendable (String) async throws -> ClaimModel
typealias FetchClaimFile = (String) async throws -> [hCore.File]

class MockFetchClaimDetailsService: hFetchClaimDetailsClient {
    var getCallCount = 0
    var getPartnerClaimCallCount = 0
    var fetchClaimDetails: FetchClaimDetail
    var fetchPartnerClaimDetails: FetchClaimDetail
    var fetchClaimFiles: FetchClaimFile
    var acknowledgeClosedStatusHandler: (String) async throws -> Void

    init(
        fetchClaimDetails: @escaping FetchClaimDetail = { _ in throw FetchClaimDetailsError.noClaimFound },
        fetchPartnerClaimDetails: @escaping FetchClaimDetail = { _ in throw FetchClaimDetailsError.noClaimFound },
        fetchClaimFiles: @escaping FetchClaimFile = { _ in [] },
        acknowledgeClosedStatusHandler: @escaping (String) async throws -> Void = { _ in }
    ) {
        self.fetchClaimDetails = fetchClaimDetails
        self.fetchPartnerClaimDetails = fetchPartnerClaimDetails
        self.fetchClaimFiles = fetchClaimFiles
        self.acknowledgeClosedStatusHandler = acknowledgeClosedStatusHandler
    }

    func get(for id: String) async throws -> ClaimModel {
        getCallCount += 1
        return try await fetchClaimDetails(id)
    }

    func getPartnerClaim(for id: String) async throws -> ClaimModel {
        getPartnerClaimCallCount += 1
        return try await fetchPartnerClaimDetails(id)
    }

    func getFiles(for id: String) async throws -> [hCore.File] {
        try await fetchClaimFiles(id)
    }

    func acknowledgeClosedStatus(for id: String) async throws {
        try await acknowledgeClosedStatusHandler(id)
    }
}
