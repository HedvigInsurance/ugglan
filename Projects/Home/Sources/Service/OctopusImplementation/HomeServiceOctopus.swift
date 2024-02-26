import Foundation
import hCore
import hGraphQL

public class HomeServiceOctopus: HomeService {
    @Inject var octopus: hOctopus

    public init() {}

    public func getImportantMessages() async throws -> [ImportantMessage] {
        octopus
            .client
            .fetch(query: OctopusGraphQL.ImportantMessagesQuery())
            .map { data in
                return data.currentMember.importantMessages.compactMap({
                    ImportantMessage(id: $0.id, message: $0.message, link: $0.link)
                })
            }
        return []
    }

    public func getMemberState() async throws -> MemberState {
        let data = try await self.octopus
            .client
            .fetch(query: OctopusGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)

        let contracts = data.currentMember.activeContracts.map { Contract(contract: $0) }
        let firstName = data.currentMember.firstName
        let contractState = data.currentMember.homeState
        let futureStatus = data.currentMember.futureStatus
        return .init(
            contracts: contracts,
            firstName: firstName,
            contractState: contractState,
            futureState: futureStatus
        )
    }

    public func getCommonClaims() async throws -> [CommonClaim] {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.CommonClaimsQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
        return data.currentMember.activeContracts
            .flatMap({ $0.currentAgreement.productVariant.commonClaimDescriptions })
            .compactMap({ CommonClaim(claim: $0) })
            .unique()
    }

    public func getLastMessagesDates() async throws -> [Date] {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.ChatMessageTimeStampQuery(until: GraphQLNullable.null),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
        return data.chat.messages.compactMap({ $0.sentAt.localDateToDate })
    }

    public func getNumberOfClaims() async throws -> Int {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.ClaimsFileQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
        return data.currentMember.claims.count
    }
}
