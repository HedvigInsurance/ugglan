import Combine
import Forever
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct DiscountsView: View {
    let data: PaymentDiscountsData
    @PresentableStore var store: CampaignStore
    @EnvironmentObject var campaignNavigationVm: CampaignNavigationViewModel
    @EnvironmentObject var router: Router

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
                DiscountDetailView(
                    discount: discount,
                    options: [.showExpire]
                )
                if discount == discountData.discounts.last {
                    Group {
                        if let info = discountData.info {
                            InfoCard(text: info, type: .info)
                        } else {
                            hRowDivider()
                        }
                    }
                }
            }
            .withHeader(title: discountData.displayName)
        }
    }

    @ViewBuilder
    private var foreverView: some View {
        let numberOfReferrals = data.referralsData.referrals.count { !$0.invitedYou }
        hSection(data.referralsData.referrals, id: \.id) { referral in
            getReferralView(referral, nbOfReferrals: numberOfReferrals)
        }
        .withHeader(
            title: L10n.ReferralsInfoSheet.headline,
            infoButtonDescription: L10n.ReferralsInfoSheet.body(
                store.state.paymentDiscountsData?.referralsData.discountPerMember
                    .formattedAmount ?? ""
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

    private func getReferralView(_ referral: Referral, nbOfReferrals: Int) -> some View {
        DiscountDetailView(
            discount: .init(referral: referral, nbOfReferrals: nbOfReferrals),
            options: [.showExpire]
        )
    }
}

struct PaymentsDiscountView_Previews: PreviewProvider {
    static var previews: some View {
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
                                discountId: "id",
                                type: .discount(status: .active)
                            ),
                            .init(
                                code: "BUNDLE",
                                displayValue: "Active",
                                description: "15% bundle discount",
                                discountId: "id1",
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
                                discountId: "id3",
                                type: .discount(status: .terminated)
                            ),
                            .init(
                                code: "BUNDLE",
                                displayValue: "Pending",
                                description: "15% bundle discount",
                                discountId: "id4",
                                type: .discount(status: .pending)
                            ),
                        ]
                    ),

                ],
                referralsData: .init(
                    code: "CODE",
                    discountPerMember: .sek(10),
                    discount: .sek(30),
                    referrals: [
                        .init(
                            id: "a1",
                            name: "Mark",
                            code: "CODE",
                            description: "desc",
                            activeDiscount: .sek(10),
                            status: .active,
                            invitedYou: true
                        ),
                        .init(
                            id: "a2",
                            name: "Idris",
                            code: "CODE",
                            description: "desc",
                            activeDiscount: .sek(10),
                            status: .active
                        ),
                        .init(
                            id: "a3",
                            name: "Atotio",
                            code: "CODE",
                            description: "desc",
                            activeDiscount: .sek(10),
                            status: .active
                        ),
                        .init(
                            id: "a4",
                            name: "SONNY",
                            code: "CODE",
                            description: "desc",
                            activeDiscount: .sek(10),
                            status: .pending
                        ),
                        .init(
                            id: "a5",
                            name: "RILLE",
                            code: "CODE",
                            description: "desc",
                            activeDiscount: .sek(30),
                            status: .terminated,
                            invitedYou: false
                        ),
                    ]
                )
            )
        )
    }
}

struct PaymentsDiscountViewNoDiscounts_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })

        return DiscountsView(
            data: .init(
                discountsData: [],
                referralsData: .init(code: "CODE", discountPerMember: .sek(10), discount: .sek(30), referrals: [])
            )
        )
    }
}

public struct PaymentsDiscountsRootView: View {
    @PresentableStore var store: CampaignStore
    @StateObject var vm = PaymentsDiscountsRootViewModel()
    @ObservedObject var campaignNavigationVm: CampaignNavigationViewModel

    public var body: some View {
        successView.loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        store.send(.fetchDiscountsData)
                    }),
                    dismissButton: nil
                )
            )
    }

    private var successView: some View {
        PresentableStoreLens(
            CampaignStore.self,
            getter: { state in
                state.paymentDiscountsData
            }
        ) { paymentDiscountsData in
            if let paymentDiscountsData {
                DiscountsView(data: paymentDiscountsData)
            }
        }
    }
}

@MainActor
class PaymentsDiscountsRootViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
    @PresentableStore var store: CampaignStore
    @Published var loadingCancellable: AnyCancellable?

    init() {
        loadingCancellable = store.loadingSignal
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] action in
                let getAction = action.first(where: { $0.key == .getDiscountsData })
                switch getAction?.value {
                case let .error(errorMessage):
                    self?.viewState = .error(errorMessage: errorMessage)
                case .loading:
                    self?.viewState = .loading
                default:
                    self?.viewState = .success
                }
            }
    }
}
