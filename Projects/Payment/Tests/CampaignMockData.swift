import hCore

@testable import Payment

struct MockCampaignData {
    static func createMockCampaignService(
        removeCampaign: @escaping RemoveCampaign = {},
        addCampaign: @escaping AddCampaign = {}
    ) -> MockCampaignService {
        let service = MockCampaignService(
            removeCampaign: removeCampaign,
            addCampaign: addCampaign
        )
        Dependencies.shared.add(module: Module { () -> hCampaignClient in service })
        return service
    }
}

enum MockCampaignError: Error {
    case failure
}

typealias RemoveCampaign = () async throws -> Void
typealias AddCampaign = () async throws -> Void

class MockCampaignService: hCampaignClient {
    var events = [Event]()

    var removeCampaign: RemoveCampaign
    var addCampaign: AddCampaign

    enum Event {
        case remove
        case add
    }

    init(
        removeCampaign: @escaping RemoveCampaign,
        addCampaign: @escaping AddCampaign
    ) {
        self.removeCampaign = removeCampaign
        self.addCampaign = addCampaign
    }

    func remove(codeId: String) async throws {
        events.append(.remove)
        try await removeCampaign()
    }

    func add(code: String) async throws {
        events.append(.add)
        try await addCampaign()
    }
}
