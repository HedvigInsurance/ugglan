import Presentation
import SwiftUI
import hCore
import hCoreUI

struct PaymentsDiscountsView: View {
    let data: PaymentDiscountsData
    @PresentableStore var store: PaymentStore
    var body: some View {
        hForm {
            VStack(spacing: 8) {
                discounts
                hSection {
                    hButton.LargeButton(type: .secondary) {
                        store.send(.navigation(to: .openAddCampaing))
                    } content: {
                        hText(L10n.paymentsAddCampaignCode)
                    }
                }
                Spacing(height: 16)
                forever
                DiscountCodeSectionView(code: data.referralsData.code)
            }
            .padding(.vertical, 16)
        }
        .sectionContainerStyle(.transparent)

    }

    private var discounts: some View {
        hSection(data.discounts) { discount in
            PaymentDetailsDiscountView(vm: .init(options: [.showExpire, .enableRemoving], discount: discount))
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
                        .foregroundColor(hTextColor.secondary)
                        .padding(.bottom, 16)
                }
            }
            .padding(.bottom, -16)
        }
    }

    private var forever: some View {
        hSection(foreverRows, id: \.id) { item in
            item.view
        }
        .withHeader {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    hText(L10n.ReferralsInfoSheet.headline)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.paymentsReferralsInfoTitle,
                        description: L10n.paymentsReferralsInfoDescription
                    )
                }
                HStack {
                    hText(data.referralsData.code, style: .standardSmall)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(hFillColor.opaqueOne)

                        )
                    Spacer()
                    hText("\(data.referralsData.discount.formattedAmount)\(L10n.perMonth)")
                        .foregroundColor(hTextColor.secondary)
                }

                if data.referralsData.referrals.count == 0 {
                    InfoCard(
                        text: L10n.ReferralsEmpty.body(data.referralsData.discountPerMember.formattedAmount),
                        type: .info
                    )
                }

            }
            .padding(.bottom, -16)
        }
    }

    private var foreverRows: [(id: String, view: AnyView)] {
        var list: [(id: String, view: AnyView)] = []

        if data.referralsData.referrals.count > 4 {
            for refferal in data.referralsData.referrals.prefix(3) {
                let refferalView = getRefferalView(refferal)
                list.append((refferal.id, AnyView(refferalView)))
            }
            list.append(("seeAllInvites", AnyView(seeAllInvitesView)))
        } else {
            for refferal in data.referralsData.referrals {
                let refferalView = getRefferalView(refferal)
                list.append((refferal.id, AnyView(refferalView)))
            }
        }
        return list
    }

    private func getRefferalView(_ referral: Referral) -> some View {
        hRow {
            ReferralView(referral: referral)
        }
        .noHorizontalPadding()
        .dividerInsets(.all, 0)
    }

    private var seeAllInvitesView: some View {
        hRow {
            hText(L10n.referralsSeeAllInvites)
        }
        .noHorizontalPadding()
        .onTap {
            store.send(.navigation(to: .openAllReferrals))
        }
        .padding(.horizontal, -16)
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
        LoadingViewWithContent(
            PaymentStore.self,
            [.getDiscountsData],
            [.fetchDiscountsData]
        ) {
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
        }
    }
}

extension PaymentsDiscountsRootView {
    var journey: some JourneyPresentation {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.fetchDiscountsData)
        return HostingJourney(
            PaymentStore.self,
            rootView: self
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case let .openInviteFriends(code, amount) = navigateTo {
                    PaymentsView.shareSheetJourney(code: code, discount: amount)
                } else if case .openChangeCode = navigateTo {
                    ChangeCodeView.journey
                } else if case .openAddCampaing = navigateTo {
                    AddCampaingCodeView.journey
                } else if case .openAllReferrals = navigateTo {
                    ReferralsView.journey
                } else if case let .openDeleteCampaing(discount) = navigateTo {
                    DeleteCampaignView.journeyWith(discount: discount)
                }
            }
        }
        .configureTitle(L10n.paymentsDiscountsSectionTitle)
    }
}

struct DiscountCodeSectionView: View {
    let code: String
    @PresentableStore var store: PaymentStore
    var body: some View {
        VStack(spacing: 0) {
            hSection {
                hFloatingField(value: code, placeholder: L10n.ReferralsEmpty.Code.headline) {
                    UIPasteboard.general.string = code
                    Toasts.shared.displayToast(
                        toast: .init(
                            symbol: .icon(hCoreUIAssets.tick.image),
                            body: L10n.ReferralsActiveToast.text
                        )
                    )
                }
                .hFieldTrailingView {
                    Image(uiImage: hCoreUIAssets.copy.image)
                }
            }
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        store.send(
                            .navigation(
                                to: .openInviteFriends(
                                    code: code,
                                    amount: store.state.paymentDiscountsData?.referralsData.discountPerMember
                                        .formattedAmount ?? ""
                                )
                            )
                        )
                    } content: {
                        hText("Invite friends")
                    }

                    hButton.LargeButton(type: .ghost) {
                        store.send(.navigation(to: .openChangeCode))
                    } content: {
                        hText(L10n.ReferralsChange.changeCode)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .presentableStoreLensAnimation(.spring())
        .sectionContainerStyle(.transparent)
    }
}

struct DiscountCodeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return DiscountCodeSectionView(code: "ASOOJRTW")
    }
}

struct ReferralView: View {
    let referral: Referral
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Circle().fill(referral.statusColor).frame(width: 14, height: 14)
                VStack(alignment: .leading) {
                    hText(referral.name).foregroundColor(hTextColor.primary)
                }
                Spacer()
                hText(referral.discountLabelText).foregroundColor(referral.discountLabelColor)
            }
            if referral.invitedYou {
                HStack(spacing: 8) {
                    Circle().fill(Color.clear).frame(width: 14, height: 14)
                    hText(L10n.ReferallsInviteeStates.invitedYou, style: .standardSmall)
                        .foregroundColor(hTextColor.secondary)
                }
            }
        }
    }
}
