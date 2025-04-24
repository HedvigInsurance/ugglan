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
                VStack(spacing: .padding8) {
                    discounts
                    if !Dependencies.featureFlags().isRedeemCampaignDisabled {
                        hSection {
                            hButton.LargeButton(type: .secondary) {
                                campaignNavigationVm.isAddCampaignPresented = true
                            } content: {
                                hText(L10n.paymentsAddCampaignCode)
                            }
                        }
                    }
                }
                forever
            }
            .padding(.vertical, .padding16)
        }
        .sectionContainerStyle(.transparent)
    }

    private var discounts: some View {
        hSection(data.discounts) { discount in
            DiscountDetailView(
                vm: .init(
                    options: [.showExpire],
                    discount: discount
                )
            )
        }
        .hWithoutHorizontalPadding([.section])
    }

    @ViewBuilder
    private var forever: some View {
        hSection(data.referralsData.referrals, id: \.id) { referral in
            getRefferalView(referral, nbOfReferrals: data.referralsData.referrals.count(where: { !$0.invitedYou }))
        }
        .withHeader(
            title: L10n.ReferralsInfoSheet.headline,
            infoButtonDescription: L10n.ReferralsInfoSheet.body(
                store.state.paymentDiscountsData?.referralsData.discountPerMember
                    .formattedAmount ?? ""
            )
        )
        .hSectionHeaderWithDivider
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

    private func getRefferalView(_ referral: Referral, nbOfReferrals: Int) -> some View {
        DiscountDetailView(
            isReferral: true,
            vm: .init(
                options: [.showExpire],
                discount: .init(referral: referral, nbOfReferrals: nbOfReferrals)
            )
        )
    }

    private func priceField(paymentDiscountsData: PaymentDiscountsData) -> some View {
        PriceField(newPremium: paymentDiscountsData.netAmount, currentPremium: paymentDiscountsData.grossAmount)
            .hWithStrikeThroughPrice(setTo: .crossOldPrice)
    }
}

struct PaymentsDiscountView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
        return DiscountsView(
            data: .init(
                discounts: [
                    .init(
                        code: "code",
                        amount: .sek(100),
                        title: nil,
                        listOfAffectedInsurances: [
                            .init(id: "id1", displayName: "name")
                        ],
                        validUntil: "2023-11-10",
                        canBeDeleted: true,
                        discountId: "id"
                    ),
                    .init(
                        code: "code 2",
                        amount: .sek(100),
                        title: "title 2",
                        listOfAffectedInsurances: [
                            .init(id: "id21", displayName: "name 2")
                        ],
                        validUntil: "2023-11-03",
                        canBeDeleted: false,
                        discountId: "id2"
                    ),
                    .init(
                        code: "code 3",
                        amount: .sek(100),
                        title: "",
                        listOfAffectedInsurances: [
                            .init(id: "id31", displayName: "name 3")
                        ],
                        validUntil: "2025-11-03",
                        canBeDeleted: false,
                        discountId: "id3"
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
                        .init(id: "a4", name: "SONNY", activeDiscount: .sek(10), status: .pending),
                        .init(
                            id: "a5",
                            name: "RILLE",
                            activeDiscount: .sek(30),
                            status: .terminated,
                            invitedYou: false
                        ),
                    ]
                ),
                netAmount: .sek(220),
                grossAmount: .sek(260)
            )
        )
    }
}

struct PaymentsDiscountViewNoDiscounts_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
        return DiscountsView(
            data: .init(
                discounts: [],
                referralsData: .init(code: "CODE", discountPerMember: .sek(10), discount: .sek(30), referrals: []),
                netAmount: .sek(220),
                grossAmount: .sek(260)
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
                        store.send(.fetchDiscountsData(paymentDataDiscounts: campaignNavigationVm.paymentDataDiscounts))
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
