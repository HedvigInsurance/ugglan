import Apollo
import Foundation
import hCore
import hGraphQL

@MainActor
public class hPaymentService {
    @Inject var client: hPaymentClient

    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData?]) {
        log.info("hPaymentService: getPaymentData", error: nil, attributes: nil)
        return try await client.getPaymentData()
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        log.info("hPaymentService: getPaymentStatusData", error: nil, attributes: nil)
        return try await client.getPaymentStatusData()
    }

    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        log.info("hPaymentService: getPaymentHistoryData", error: nil, attributes: nil)
        return try await client.getPaymentHistoryData()
    }

    public func getConnectPaymentUrl() async throws -> URL {
        log.info("hPaymentService: getConnectPaymentUrl", error: nil, attributes: nil)
        return try await client.getConnectPaymentUrl()
    }
}

public class hPaymentClientOctopus: hPaymentClient {
    @Inject private var octopus: hOctopus

    public init() {}

    public func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData]) {
        let query = OctopusGraphQL.PaymentDataQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

        let paymentDetailsQuery = OctopusGraphQL.PaymentInformationQuery()
        let paymentDetailsData = try await octopus.client.fetch(
            query: paymentDetailsQuery,
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        let paymentDetails = PaymentData.PaymentDetails(with: paymentDetailsData)
        let upcomingPayment = PaymentData(with: data, paymentDetails: paymentDetails)
        let ongoingPayments: [PaymentData] = data.currentMember.ongoingCharges.compactMap({
            .init(with: $0.fragments.memberChargeFragment, paymentDataQueryCurrentMember: data.currentMember)
        })
        return (upcomingPayment, ongoingPayments)

    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        let query = OctopusGraphQL.PaymentInformationQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentStatusData(data: data)
    }

    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        let query = OctopusGraphQL.PaymentHistoryDataQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentHistoryListData.getHistory(with: data.currentMember)
    }

    public func getConnectPaymentUrl() async throws -> URL {
        let mutation = OctopusGraphQL.RegisterDirectDebitMutation(clientContext: GraphQLNullable.none)
        let data = try await octopus.client.perform(mutation: mutation)
        if let url = URL(string: data.registerDirectDebit2.url) {
            return url
        }
        throw PaymentError.missingDataError(message: L10n.General.errorBody)
    }
}
