import Foundation
import hCore
import hGraphQL

public protocol hCampaignsService {
    func remove(code: String) async throws
    func add(code: String) async throws
}

public class hCampaignsServiceDemo: hCampaignsService {

    public init() {}
    public func remove(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    public func add(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

public class hCampaingsServiceOctopus: hCampaignsService {
    @Inject private var octopus: hOctopus
    public init() {}
    public func remove(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw CampaignsError.notImplemented
    }

    public func add(code: String) async throws {
        let data = try await octopus.client.perform(mutation: OctopusGraphQL.RedeemCodeMutation(code: code))
        if let errorMessage = data.memberCampaignsRedeem.userError?.message {
            throw CampaignsError.userError(message: errorMessage)
        }
    }
}

enum CampaignsError: Error {
    case userError(message: String)
    case notImplemented
}

extension CampaignsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .userError(message):
            return message
        case .notImplemented:
            return L10n.General.errorBody
        }
    }
}
