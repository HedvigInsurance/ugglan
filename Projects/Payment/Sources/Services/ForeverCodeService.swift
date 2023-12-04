import Foundation
import hCore
import hGraphQL

public protocol hForeverCodeService {
    func chageCode(new code: String) async throws
}

public class hForeverCodeServiceOctopus: hForeverCodeService {

    @Inject private var octopus: hOctopus
    public init() {}
    public func chageCode(new code: String) async throws {
        let data = try await octopus.client.perform(
            mutation: OctopusGraphQL.MemberReferralInformationCodeUpdatePaymentMutation(code: code)
        )
        if let message = data.memberReferralInformationCodeUpdate.userError?.message {
            throw NetworkError.badRequest(message: message)
        }
    }
}

public class hForeverCodeServiceDemo: hForeverCodeService {
    @Inject var octopus: hOctopus
    public init() {}

    public func chageCode(new code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw NetworkError.badRequest(message: "Bad request")

    }
}
