import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

public class ForeverServiceGraphQL: ForeverService {
    public func changeDiscountCode(_ value: String) -> Signal<Either<Void, ForeverChangeCodeError>> {
        giraffe.client
            .perform(
                mutation: GiraffeGraphQL.ForeverUpdateDiscountCodeMutation(code: value)
            )
            .valueSignal
            .map { data -> Either<Void, ForeverChangeCodeError> in
                let updateReferralCampaignCode = data.updateReferralCampaignCode

                if updateReferralCampaignCode.asCodeAlreadyTaken != nil {
                    return .right(ForeverChangeCodeError.nonUnique)
                } else if updateReferralCampaignCode.asCodeTooLong != nil {
                    return .right(ForeverChangeCodeError.tooLong)
                } else if updateReferralCampaignCode.asCodeTooShort != nil {
                    return .right(ForeverChangeCodeError.tooShort)
                } else if let maximumUpdates = updateReferralCampaignCode.asExceededMaximumUpdates {
                    return .right(
                        ForeverChangeCodeError.exceededMaximumUpdates(
                            amount: maximumUpdates.maximumNumberOfUpdates
                        )
                    )
                } else if updateReferralCampaignCode.asSuccessfullyUpdatedCode != nil {
                    self.giraffe.store.withinReadWriteTransaction(
                        { transaction in
                            try transaction.update(query: GiraffeGraphQL.ForeverQuery()) {
                                (data: inout GiraffeGraphQL.ForeverQuery.Data) in
                                data.referralInformation.campaign.code = value
                            }
                        },
                        completion: nil
                    )

                    return .left(())
                }

                return .right(ForeverChangeCodeError.unknown)
            }
            .plain()
    }

    public var dataSignal: ReadSignal<ForeverData?> {
        giraffe.client.watch(query: GiraffeGraphQL.ForeverQuery())
            .map { data -> ForeverData in
                let grossAmount = data.referralInformation.costReducedIndefiniteDiscount?.monthlyGross
                let grossAmountMonetary = MonetaryAmount(
                    amount: grossAmount?.amount ?? "",
                    currency: grossAmount?.currency ?? ""
                )

                let netAmount = data.referralInformation.costReducedIndefiniteDiscount?.monthlyNet
                let netAmountMonetary = MonetaryAmount(
                    amount: netAmount?.amount ?? "",
                    currency: netAmount?.currency ?? ""
                )

                let potentialDiscountAmount = data.referralInformation.campaign.incentive?
                    .asMonthlyCostDeduction?
                    .amount
                let potentialDiscountAmountMonetary = MonetaryAmount(
                    amount: potentialDiscountAmount?.amount ?? "",
                    currency: potentialDiscountAmount?.currency ?? ""
                )

                let discountCode = data.referralInformation.campaign.code

                var invitations = data.referralInformation.invitations
                    .map { invitation -> ForeverInvitation? in
                        if let inProgress = invitation.asInProgressReferral {
                            return .init(
                                name: inProgress.name ?? "",
                                state: .pending,
                                discount: nil,
                                invitedByOther: false
                            )
                        } else if let active = invitation.asActiveReferral {
                            let discount = active.discount
                            return .init(
                                name: active.name ?? "",
                                state: .active,
                                discount: MonetaryAmount(
                                    amount: discount.amount,
                                    currency: discount.currency
                                ),
                                invitedByOther: false
                            )
                        } else if let terminated = invitation.asTerminatedReferral {
                            return .init(
                                name: terminated.name ?? "",
                                state: .terminated,
                                discount: nil,
                                invitedByOther: false
                            )
                        }

                        return nil
                    }
                    .compactMap { $0 }

                let referredBy = data.referralInformation.referredBy

                if let inProgress = referredBy?.asInProgressReferral {
                    invitations.insert(
                        .init(
                            name: inProgress.name ?? "",
                            state: .pending,
                            discount: nil,
                            invitedByOther: true
                        ),
                        at: 0
                    )
                } else if let active = referredBy?.asActiveReferral {
                    let discount = active.discount
                    invitations.insert(
                        .init(
                            name: active.name ?? "",
                            state: .active,
                            discount: MonetaryAmount(
                                amount: discount.amount,
                                currency: discount.currency
                            ),
                            invitedByOther: true
                        ),
                        at: 0
                    )
                } else if let terminated = referredBy?.asTerminatedReferral {
                    invitations.insert(
                        .init(
                            name: terminated.name ?? "",
                            state: .terminated,
                            discount: nil,
                            invitedByOther: true
                        ),
                        at: 0
                    )
                }
                let otherDiscounts: MonetaryAmount? = {

                    let referalDiscounts = invitations.compactMap({ $0.discount?.floatAmount }).reduce(0) { $0 + $1 }
                    let gross = grossAmountMonetary.floatAmount
                    let net = netAmountMonetary.floatAmount
                    if gross - referalDiscounts > net {
                        return .init(amount: gross - net - referalDiscounts, currency: grossAmountMonetary.currency)
                    }
                    return nil
                }()

                return .init(
                    grossAmount: grossAmountMonetary,
                    netAmount: netAmountMonetary,
                    potentialDiscountAmount: potentialDiscountAmountMonetary,
                    otherDiscounts: otherDiscounts,
                    discountCode: discountCode,
                    invitations: invitations
                )
            }
            .readable(initial: nil)
    }

    public func refetch() {
        giraffe.client.fetch(query: GiraffeGraphQL.ForeverQuery(), cachePolicy: .fetchIgnoringCacheData).sink()
    }

    public init() {}

    @Inject var giraffe: hGiraffe
}
