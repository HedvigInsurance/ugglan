import Contracts
import Foundation
import hGraphQL

public struct PaymentData: Codable, Equatable {
    let nextPayment: NextPayment?
    let contracts: [ContractInfo]?
    let insuranceCost: MonetaryStack?
    let chargeEstimation: MonetaryStack?
    let paymentHistory: [PaymentHistory]?
    var reedemCampaigns: [ReedemCampaign]
    init(_ data: OctopusGraphQL.PaymentDataQuery.Data) {
        let currentMember = data.currentMember
        nextPayment = NextPayment(currentMember.upcomingCharge)
        contracts = currentMember.activeContracts.map({ .init($0) })
        insuranceCost = MonetaryStack(currentMember.insuranceCost)
        chargeEstimation = MonetaryStack(currentMember.upcomingCharge)
        paymentHistory = currentMember.chargeHistory.map({ PaymentHistory($0) })
        reedemCampaigns = currentMember.redeemedCampaigns.compactMap({ .init($0) })
    }

    struct NextPayment: Codable, Equatable {
        let amount: MonetaryAmount?
        let date: String?

        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.UpcomingCharge?) {
            guard let data else { return nil }
            amount = MonetaryAmount(optionalFragment: data.net.fragments.moneyFragment)
            date = data.date.localDateToDate?.displayDateMMMDDYYYYFormat
        }
    }

    struct ContractInfo: Codable, Equatable {
        let id: String
        let type: Contract.TypeOfContract
        let name: String
        let amount: MonetaryAmount?

        init(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.ActiveContract) {
            self.id = data.id
            self.name = data.currentAgreement.productVariant.displayName
            self.type =
                Contract.TypeOfContract(rawValue: data.currentAgreement.productVariant.typeOfContract)
                ?? .unknown
            self.amount = nil
        }
    }

    struct PaymentHistory: Codable, Equatable {
        let amount: MonetaryAmount
        let date: String

        init(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.ChargeHistory) {
            amount = MonetaryAmount(fragment: data.amount.fragments.moneyFragment)
            let localDate = data.date.localDateToDate?.displayDateMMMDDYYYYFormat ?? ""
            date = localDate
        }
    }

    struct ReedemCampaign: Codable, Equatable {
        let code: String?
        let displayValue: String?
        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.RedeemedCampaign?) {
            guard let data else { return nil }
            code = data.code
            displayValue = data.description
        }
    }

    struct MonetaryStack: Codable, Equatable {
        let gross: MonetaryAmount?
        let discount: MonetaryAmount?
        let net: MonetaryAmount?

        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.UpcomingCharge?) {
            guard let data else { return nil }
            self.gross = MonetaryAmount(fragment: data.gross.fragments.moneyFragment)
            self.discount = MonetaryAmount(fragment: data.discount.fragments.moneyFragment)
            self.net = MonetaryAmount(fragment: data.net.fragments.moneyFragment)
        }

        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.InsuranceCost) {
            self.gross = MonetaryAmount(fragment: data.monthlyGross.fragments.moneyFragment)
            self.discount = MonetaryAmount(fragment: data.monthlyDiscount.fragments.moneyFragment)
            self.net = MonetaryAmount(fragment: data.monthlyNet.fragments.moneyFragment)
        }

    }
}
