import Presentation
import SwiftUI
import hCore
import hCoreUI

struct PaymentsDiscountsView: View {
    let data: PaymentDiscountsData
    var body: some View {
        hForm {
            VStack(spacing: 8) {
                discounts
                hSection {
                    hButton.LargeButton(type: .secondary) {

                    } content: {
                        hText("Add campaign code")
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
            PaymentDetailsDiscountView(vm: .init(options: [.showExpire], discount: discount))
        }
        .withHeader {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    hText("Campaigns")
                    Spacer()
                    InfoViewHolder(
                        title: "",
                        description: ""
                    )
                }
                if data.discounts.count == 0 {
                    hText("No campaign code added")
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
                    hText("Hedvig Forever")
                    Spacer()
                    InfoViewHolder(
                        title: "",
                        description: ""
                    )
                }
                HStack {
                    hText(data.referralsData.code)
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

    private func getRefferalView(_ refferal: Referral) -> some View {
        hRow {
            HStack(spacing: 8) {
                Circle().fill(refferal.statusColor).frame(width: 14, height: 14)
                VStack(alignment: .leading) {
                    hText(refferal.name).foregroundColor(hTextColor.primary)
                }
                Spacer()
                hText(refferal.discountLabelText).foregroundColor(refferal.discountLabelColor)

            }
        }
        .noHorizontalPadding()
        .dividerInsets(.all, 0)
    }

    private var seeAllInvitesView: some View {
        hRow {
            hText("See all invites")
        }
        .noHorizontalPadding()
        .onTap {

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
                        validUntil: "2023-11-10"
                    ),
                    .init(
                        id: "id2",
                        code: "code 2",
                        amount: .sek(100),
                        title: "title 2",
                        listOfAffectedInsurances: [
                            .init(id: "id21", displayName: "name 2")
                        ],
                        validUntil: "2023-11-03"
                    ),
                ],
                referralsData: .init(
                    code: "CODE",
                    discountPerMember: .sek(10),
                    discount: .sek(30),
                    referrals: [
                        .init(id: "a1", name: "Mark", activeDiscount: .sek(10), status: .active),
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
        .onAppear {
            store.send(.fetchDiscountsData)
        }
    }
}

extension PaymentsDiscountsRootView {
    var journey: some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: self
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case let .openInviteFriends(code, amount) = navigateTo {
                    PaymentsView.shareSheetJourney(code: code, discount: amount)
                } else if case .openChangeCode = navigateTo {
                    ChangeCodeView.journey
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
