import EditCoInsuredShared
import Foundation
import hCore
import hCoreUI

@MainActor
public protocol EditCoInsuredClient {
    func sendMidtermChangeIntentCommit(commitId: String) async throws
    func getPersonalInformation(SSN: String) async throws -> PersonalData?
    func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent
}

public enum CoInsuredAction: Codable, Identifiable {
    public var id: Self {
        self
    }

    case delete
    case edit
    case add
}

extension CoInsuredAction: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: SuccessScreen.self)
    }
}

public enum EditCoInsuredError: Error {
    case serviceError(message: String)
    case missingSSN
    case otherError
}

extension EditCoInsuredError: LocalizedError {
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
