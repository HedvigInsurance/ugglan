import Foundation
import hGraphQL

@MainActor
extension PaymentStatusData {
    init(data: OctopusGraphQL.PaymentInformationQuery.Data) {
        self.status = {
            if data.currentMember.activeContracts.isEmpty && data.currentMember.pendingContracts.isEmpty {
                return .noNeedToConnect
            }

            let missedPaymentsContracts = data.currentMember.activeContracts.filter({
                $0.terminationDueToMissedPayments
            })
            if !missedPaymentsContracts.isEmpty {
                if let date = missedPaymentsContracts.compactMap({ $0.terminationDate?.localDateToDate }).sorted()
                    .first?
                    .displayDateDDMMMYYYYFormat
                {
                    return .contactUs(date: date)
                }
            }

            return data.currentMember.paymentInformation.status.asPayinMethodStatus
        }()
        self.displayName = data.currentMember.paymentInformation.connection?.displayName
        self.descriptor = data.currentMember.paymentInformation.connection?.descriptor
    }
}
