import Forever
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PaymentsDiscountsView: View {
    let data: PaymentDiscountsData
    @PresentableStore var store: PaymentStore
    @EnvironmentObject var paymentsNavigationVm: PaymentsNavigationViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        hForm {
            VStack(spacing: 8) {
                discounts
                hSection {
                    hButton.LargeButton(type: .secondary) {
                        paymentsNavigationVm.isAddCampaignPresented = true
                    } content: {
                        hText(L10n.paymentsAddCampaignCode)
                    }
                }
                Spacing(height: 16)
                forever
            }
            .padding(.vertical, .padding16)
        }
        .sectionContainerStyle(.transparent)

    }

    private var discounts: some View {
        hSection(data.discounts) { discount in
            PaymentDetailsDiscountView(
                vm: .init(
                    options: [.showExpire],
                    discount: discount
                )
            )
        }
        .withHeader {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    hText(L10n.paymentsCampaigns)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.paymentsCampaignsInfoTitle,
                        description: L10n.paymentsCampaignsInfoDescription
                    )
                }
                if data.discounts.count == 0 {
                    hText(L10n.paymentsNoCampaignCodeAdded)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .padding(.bottom, .padding16)
                }
            }
            .padding(.bottom, -16)
        }
    }

    @ViewBuilder
    private var forever: some View {
        hSection(data.referralsData.referrals, id: \.id) { item in
            getRefferalView(item)
        }
        .withHeader {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    hText(L10n.ReferralsInfoSheet.headline)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.paymentsReferralsInfoTitle,
                        description: L10n.ReferralsInfoSheet.body(
                            store.state.paymentDiscountsData?.referralsData.discountPerMember
                                .formattedAmount ?? ""
                        )
                    )
                }
                HStack {
                    hText(data.referralsData.code, style: .label)
                        .padding(.horizontal, .padding8)
                        .padding(.vertical, .padding4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(hSurfaceColor.Opaque.primary)

                        )
                    Spacer()
                    hText(
                        "\(data.referralsData.allReferralDiscount.formattedNegativeAmount)/\(L10n.monthAbbreviationLabel)"
                    )
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .padding(.bottom, data.referralsData.referrals.isEmpty ? 0 : -16)
        }
        hSection {
            InfoCard(
                text: L10n.ReferralsEmpty.body(data.referralsData.discountPerMember.formattedAmount),
                type: .campaign
            )
            .buttons(
                [
                    .init(
                        buttonTitle: L10n.paymentsInviteFriends,
                        buttonAction: {
                            router.push(PaymentsRedirectType.forever)
                        }
                    )
                ]
            )
            .padding(.bottom, .padding8)
        }
    }

    private func getRefferalView(_ referral: Referral) -> some View {
        hRow {
            ReferralView(referral: referral)
        }
        .hWithoutHorizontalPadding
        .dividerInsets(.all, 0)
    }
}

struct PaymentsDiscountView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsDiscountsView(
            data: .init(
                discounts: [
                    .init(
                        id: "id",
                        code: "code",
                        amount: .sek(100),
                        title: "title",
                        listOfAffectedInsurances: [
                            .init(id: "id1", displayName: "name")
                        ],
                        validUntil: "2023-11-10",
                        canBeDeleted: true
                    ),
                    .init(
                        id: "id2",
                        code: "code 2",
                        amount: .sek(100),
                        title: "title 2",
                        listOfAffectedInsurances: [
                            .init(id: "id21", displayName: "name 2")
                        ],
                        validUntil: "2023-11-03",
                        canBeDeleted: false
                    ),
                ],
                referralsData: .init(
                    code: "CODE",
                    discountPerMember: .sek(10),
                    discount: .sek(30),
                    referrals: [
                        .init(id: "a1", name: "Mark", activeDiscount: .sek(10), status: .active, invitedYou: true),
                        .init(id: "a2", name: "Idris", activeDiscount: .sek(10), status: .active),
                        .init(id: "a3", name: "Atotio", activeDiscount: .sek(10), status: .active),
                        .init(id: "a4", name: "Mark", activeDiscount: .sek(10), status: .pending),
                        .init(id: "a5", name: "Mark", activeDiscount: .sek(10), status: .terminated),
                    ]
                )
            )
        )
    }
}

struct PaymentsDiscountViewNoDiscounts_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsDiscountsView(
            data: .init(
                discounts: [],
                referralsData: .init(code: "CODE", discountPerMember: .sek(10), discount: .sek(30), referrals: [])
            )
        )
    }
}

struct PaymentsDiscountsRootView: View {
    @PresentableStore var store: PaymentStore
    var body: some View {
        //        LoadingStoreViewWithContent(
        //            PaymentStore.self,
        //            [.getDiscountsData],
        //            [.fetchDiscountsData]
        //        ) {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentDiscountsData
            }
        ) { paymentDiscountsData in
            if let paymentDiscountsData {
                PaymentsDiscountsView(data: paymentDiscountsData)
            }
        }
        //        }
    }
}

struct ReferralView: View {
    let referral: Referral
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Circle().fill(referral.statusColor).frame(width: 14, height: 14)
                VStack(alignment: .leading) {
                    hText(referral.name).foregroundColor(hTextColor.Opaque.primary)
                }
                Spacer()
                hText(referral.discountLabelText).foregroundColor(referral.discountLabelColor)
            }
            if referral.invitedYou {
                HStack(spacing: 8) {
                    Circle().fill(Color.clear).frame(width: 14, height: 14)
                    hText(L10n.ReferallsInviteeStates.invitedYou, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
    }
}
