import Campaign
import Foundation
import PresentableStore
import hCore
import hGraphQL

class hCampaignsClientOctopus: hCampaignClient {
    @Inject private var octopus: hOctopus

    func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        let query = OctopusGraphQL.DiscountsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentDiscountsData(with: data, amountFromPaymentData: nil)
    }
}

@MainActor
extension PaymentDiscountsData {
    init(
        with data: OctopusGraphQL.DiscountsQuery.Data,
        amountFromPaymentData: MonetaryAmount?
    ) {
        var discountData = [DiscountsDataForInsurance]()
        let activeContractsDiscountData: [DiscountsDataForInsurance?] = data.currentMember.activeContracts.map {
            contract in
            let discounts = contract.discountsDetails.discounts
                .map { $0.fragments.contractDiscountDetailsItemFragment }
                .map { item in
                    Discount.init(with: item)
                }
            if discounts.isEmpty { return nil }
            let displayName =
                (contract.currentAgreement.productVariant.displayNameShort ?? "") + " • "
                + contract.exposureDisplayNameShort
            return DiscountsDataForInsurance.init(id: contract.id, displayName: displayName, discount: discounts)
        }
        discountData.append(contentsOf: activeContractsDiscountData.compactMap { $0 })
        let pendingContractsDiscountData: [DiscountsDataForInsurance?] = data.currentMember.pendingContracts.map {
            contract in
            let discounts = contract.discountsDetails.discounts
                .map { $0.fragments.contractDiscountDetailsItemFragment }
                .map { item in
                    Discount.init(with: item)
                }
            if discounts.isEmpty { return nil }
            let displayName =
                (contract.productVariant.displayNameShort ?? "") + " • " + contract.exposureDisplayNameShort

            return DiscountsDataForInsurance.init(id: contract.id, displayName: displayName, discount: discounts)
        }
        discountData.append(contentsOf: pendingContractsDiscountData.compactMap { $0 })

        self.init(
            discountsData: discountData,
            referralsData: .init(with: data.currentMember.referralInformation)
        )
    }
}

@MainActor
extension Discount {
    init(
        with data: OctopusGraphQL.ContractDiscountDetailsItemFragment
    ) {
        let status: DiscountStatus = {
            switch data.discountStatus {
            case .case(let status):
                switch status {
                case .active:
                    return .ACTIVE
                case .pending:
                    return .PENDING
                case .terminated:
                    return .TERMINATED
                }
            case .unknown:
                return .ACTIVE
            }
        }()
        self.init(
            code: data.campaignCode,
            displayValue: data.statusDescription,
            description: data.description,
            discountId: data.campaignCode,
            type: .discount(status: status)
        )
        //        self.init(
        //            code: data.code,
        //            amount: amountFromPaymentData,
        //            title: data.description,
        //            listOfAffectedInsurances: data.onlyApplicableToContracts?
        //                .compactMap {
        //                    .init(
        //                        id: $0.id,
        //                        displayName: $0.getDisplayName
        //                    )
        //                } ?? [],
        //            validUntil: data.expiresAt,
        //            canBeDeleted: true,
        //            discountId: data.id
        //        )
    }
    public init(
        with moneyFragment: OctopusGraphQL.MoneyFragment,
        discountDto discount: ReedeemedCampaingDTO?
    ) {
        self.init(
            code: discount?.code ?? "",
            displayValue: MonetaryAmount(fragment: moneyFragment).formattedAmount,
            description: discount?.description,
            discountId: discount?.code ?? "",
            type: .paymentsDiscount
        )
    }
}

extension OctopusGraphQL.MemberReferralInformationCodeFragment {
    public func asReedeemedCampaing() -> ReedeemedCampaingDTO {
        .init(
            code: code,
            description: L10n.paymentsReferralDiscount
        )
    }
}

public struct ReedeemedCampaingDTO {
    let code: String
    let description: String
}

extension ReferralsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.ReferralInformation) {
        var referrals: [Referral] = []
        if let invitedBy = data.referredBy?.fragments.memberReferralFragment2 {
            referrals.append(.init(with: invitedBy, invitedYou: true))
        }
        let amount = data.referrals.reduce(0) { partialResult, referal in
            if referal.status == .active {
                return partialResult + (referal.activeDiscount?.amount ?? 0)
            }
            return partialResult
        }
        let numberOfReferrals = data.referrals.filter { $0.status == .active }.count
        referrals.append(
            .init(
                id: UUID().uuidString,
                name: data.code,
                code: data.code,
                description: L10n.foreverReferralInvitedByYouPlural(numberOfReferrals),
                activeDiscount: MonetaryAmount(
                    amount: Float(amount),
                    currency: data.monthlyDiscountPerReferral.fragments.moneyFragment.currencyCode.rawValue
                ),
                status: .active
            )
        )
        self.init(
            code: data.code,
            discountPerMember: .init(fragment: data.monthlyDiscountPerReferral.fragments.moneyFragment),
            discount: .sek(10),
            referrals: referrals.reversed()
        )
    }
}

extension Referral {
    init(with data: OctopusGraphQL.MemberReferralFragment2, invitedYou: Bool = false) {
        self.init(
            id: UUID().uuidString,
            name: data.name,
            code: data.code,
            description: L10n.Forever.Referral.invitedYou(data.name),
            activeDiscount: .init(optionalFragment: data.activeDiscount?.fragments.moneyFragment),
            status: data.status.asReferralState,
            invitedYou: invitedYou
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.MemberReferralStatus> {
    var asReferralState: Referral.State {
        switch self {
        case let .case(t):
            switch t {
            case .pending:
                return .pending
            case .active:
                return .active
            case .terminated:
                return .terminated
            }
        case .unknown:
            return .unknown
        }
    }
}
