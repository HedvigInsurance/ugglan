import Foundation
import hCore
import hCoreUI

@MainActor
public protocol EditStakeholdersClient {
    func commitMidtermChange(commitId: String) async throws
    func fetchPersonalInformation(SSN: String) async throws -> PersonalData?
    func createIntent(
        contractId: String,
        stakeholders: [Stakeholder],
        type: StakeholderType
    ) async throws -> Intent
    func fetchContracts() async throws -> [Contract]
}

public enum StakeholderAction: Codable, Identifiable {
    public var id: Self {
        self
    }

    case delete
    case edit
    case add
}

extension StakeholderAction: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SuccessScreen.self)
    }
}

public enum EditStakeholdersError: Error {
    case serviceError(message: String)
    case missingSSN
    case otherError
}

extension EditStakeholdersError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .serviceError(message): return message
        case .missingSSN:
            return L10n.coinsuredSsnNotFound
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
