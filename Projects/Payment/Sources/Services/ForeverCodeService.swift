import Foundation
import hCore
import hGraphQL

public protocol hForeverCodeService {
    func chageCode(new code: String) async throws
}

public class a: hForeverCodeService {
    @Inject var octopus: hOctopus
    public init() {}
    public func chageCode(new code: String) async throws {
        _ = try await octopus.client.perform(
            mutation: OctopusGraphQL.MemberReferralInformationCodeUpdatePaymentMutation(code: code)
        )
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
