import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct ForeverState: StateProtocol {
    public var hasSeenFebruaryCampaign: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenFebruaryCampaign, forKey: Self.hasSeenFebruaryCampaignKey)
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate static var hasSeenFebruaryCampaignKey: String {
        "ForeverFebruaryCampaign-hasBeenSeen"
    }

    public init() {
        self.hasSeenFebruaryCampaign = false
    }

    var foreverData: ForeverData? = nil
}

public enum ForeverAction: ActionProtocol {
    case hasSeenFebruaryCampaign(value: Bool)
    case showTemporaryCampaignDetail
    case fetch
    case setForeverData(data: ForeverData)
}

public final class ForeverStore: StateStore<ForeverState, ForeverAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) -> FiniteSignal<ForeverAction>? {
        switch action {
        case .fetch:
            return client.fetch(query: GraphQL.ForeverQuery())
                .valueThenEndSignal
                .map { data in
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

                    return .setForeverData(
                        data: .init(
                            grossAmount: grossAmountMonetary,
                            netAmount: netAmountMonetary,
                            potentialDiscountAmount: potentialDiscountAmountMonetary,
                            discountCode: discountCode,
                            invitations: invitations
                        )
                    )
                }
        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: ForeverState, _ action: ForeverAction) -> ForeverState {
        var newState = state

        switch action {
        case let .hasSeenFebruaryCampaign(hasSeenFebruaryCampaign):
            newState.hasSeenFebruaryCampaign = hasSeenFebruaryCampaign
        case let .setForeverData(data):
            newState.foreverData = data
        case .fetch:
            break
        case .showTemporaryCampaignDetail:
            break
        }

        return newState
    }
}
