import CampaignCore
import SwiftUI
import hCore
import hCoreUI

struct DiscountsView: View {
    let data: PaymentDiscountsData
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                discountsView
                foreverView
            }
            .fixedSize(horizontal: false, vertical: true)
            .hWithoutHorizontalPadding([.row, .divider])
            .hSectionHeaderWithDivider
            .padding(.vertical, .padding16)
        }
        .sectionContainerStyle(.transparent)
    }

    private var discountsView: some View {
        ForEach(data.discountsData, id: \.id) { discountData in
            hSection(discountData.discounts) { discount in
                Group {
                    DiscountDetailView(discount: discount)
                    if discount == discountData.discounts.last, let info = discountData.info {
                        InfoCard(text: info, type: .info)
                    }
                }
            }
            .withHeader(title: discountData.displayName)
        }
    }

    @ViewBuilder
    private var foreverView: some View {
        hSection(data.referralsData.referrals, id: \.id) { referral in
            getReferralView(referral)
        }
        .withHeader(
            title: L10n.ReferralsInfoSheet.headline,
            infoButtonDescription: L10n.ReferralsInfoSheet.body(
                data.referralsData.discountPerMember.formattedAmount
            )
        )
        .hWithoutHorizontalPadding([.row, .divider])

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
                            router.push(CampaignRouterAction.forever)
                        }
                    )
                ]
            )
            .padding(.bottom, .padding8)
        }
    }

    private func getReferralView(_ referral: Referral) -> some View {
        DiscountDetailView(
            discount: .init(referral: referral)
        )
    }
}

#Preview("PaymentsDiscountView") {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })

    return DiscountsView(
        data: .init(
            discountsData: [
                .init(
                    id: "id1",
                    displayName: "Dog Premium ∙ Fido",
                    info: "Your insurance info",
                    discounts: [
                        .init(
                            code: "FURRY",
                            displayValue: "Active",
                            description: "50% discount for 6 months",
                            type: .discount(status: .active)
                        ),
                        .init(
                            code: "BUNDLE",
                            displayValue: "Active",
                            description: "15% bundle discount",
                            type: .discount(status: .active)
                        ),
                    ]
                ),
                .init(
                    id: "id2",
                    displayName: "House Standard ∙ Villagatan 25",
                    info: nil,
                    discounts: [
                        .init(
                            code: "TOGETHER",
                            displayValue: "Expired 31 aug 2025",
                            description: "15% discount for 12 months",
                            type: .discount(status: .terminated)
                        ),
                        .init(
                            code: "BUNDLE",
                            displayValue: "Pending",
                            description: "15% bundle discount",
                            type: .discount(status: .pending)
                        ),
                    ]
                ),

            ],
            referralsData: .init(
                discountPerMember: .sek(10),
                referrals: [
                    .init(
                        id: "a1",
                        name: "Mark",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "a2",
                        name: "Idris",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "a3",
                        name: "Atotio",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "a4",
                        name: "SONNY",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "a5",
                        name: "RILLE",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(30)
                    ),
                ]
            )
        )
    )
}

#Preview("PaymentsDiscountViewNoDiscounts") {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })

    return DiscountsView(
        data: .init(
            discountsData: [],
            referralsData: .init(discountPerMember: .sek(10), referrals: [])
        )
    )
}

public struct PaymentsDiscountsRootView: View {
    @StateObject var vm = PaymentsDiscountsRootViewModel()

    public init() {}

    public var body: some View {
        successView.loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: { [weak vm] in
                        vm?.fetch()
                    }),
                    dismissButton: nil
                )
            )
            .task { [weak vm] in
                vm?.fetch()
            }
    }

    @ViewBuilder
    private var successView: some View {
        if let data = vm.paymentDiscountsData {
            DiscountsView(data: data)
        }
    }
}
