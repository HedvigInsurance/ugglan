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

    public var foreverData: ForeverData? = nil
}

public indirect enum ForeverAction: ActionProtocol {
    case hasSeenFebruaryCampaign(value: Bool)
    case showChangeCodeDetail
    case dismissChangeCodeDetail
    case fetch
    case setForeverData(data: ForeverData)
    case showShareSheetWithNotificationReminder(code: String)
    case showInfoSheet(discount: String)
    case closeInfoSheet
    case showShareSheetOnly(code: String)
    case showPushNotificationsReminder
    case dismissPushNotificationSheet
}

public final class ForeverStore: StateStore<ForeverState, ForeverAction> {
    @Inject var giraffe: hGiraffe

    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) -> FiniteSignal<ForeverAction>? {
        switch action {
        case .fetch:
            return giraffe.client.fetch(query: GiraffeGraphQL.ForeverQuery())
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

                    let otherDiscounts: MonetaryAmount? = {

                        let referalDiscounts = invitations.compactMap({ $0.discount?.floatAmount })
                            .reduce(0) { $0 + $1 }
                        let gross = grossAmountMonetary.floatAmount
                        let net = netAmountMonetary.floatAmount
                        if gross - referalDiscounts > net {
                            return .init(amount: gross - net - referalDiscounts, currency: grossAmountMonetary.currency)
                        }
                        return nil
                    }()

                    return .setForeverData(
                        data: .init(
                            grossAmount: grossAmountMonetary,
                            netAmount: netAmountMonetary,
                            potentialDiscountAmount: potentialDiscountAmountMonetary,
                            otherDiscounts: otherDiscounts,
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
        default:
            break
        }

        return newState
    }
}
