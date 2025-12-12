import Claims
import Foundation
import SubmitClaimChat
import hCore
import hGraphQL

class ClaimIntentMemberClientOctopus: ClaimIntentMemberClient {
    @Inject private var octopus: hOctopus

    func fetchPhoneNumber() async throws -> String? {
        let query = OctopusGraphQL.CurrentMemberPhoneNumberQuery()
        let data = try await octopus.client.fetch(query: query)
        return data.currentMember.phoneNumber
    }

    func updatePhoneNumber(phoneNumber: String) async throws {
        let mutation = OctopusGraphQL.MemberUpdatePhoneNumberMutation(
            input: .init(
                phoneNumber: phoneNumber
            )
        )
        let data = try await octopus.client.mutation(mutation: mutation)
        if let error = data?.memberUpdatePhoneNumber.userError?.message {
            throw ClaimIntentError.error(message: error)
        }
    }
}
