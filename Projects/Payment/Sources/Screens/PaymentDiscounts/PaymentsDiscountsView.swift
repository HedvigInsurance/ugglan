import Combine
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
            VStack(spacing: .padding8) {
                discounts
                if !Dependencies.featureFlags().isRedeemCampaignDisabled {
                    hSection {
                        hButton.LargeButton(type: .secondary) {
                            paymentsNavigationVm.isAddCampaignPresented = true
                        } content: {
                            hText(L10n.paymentsAddCampaignCode)
                        }
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
        .withHeader(
            title: L10n.paymentsCampaigns,
            infoButtonDescription: !Dependencies.featureFlags().isRedeemCampaignDisabled
                ? L10n.paymentsCampaignsInfoDescription : nil,
            withoutBottomPadding: true,
            extraView: data.discounts.count == 0
                ? (
                    view: hText(L10n.paymentsNoCampaignCodeAdded)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .padding(.bottom, .padding16)
                        .asAnyView,
                    alignment: .bottom
                ) : nil
        )
    }

    @ViewBuilder
    private var forever: some View {
        hSection(data.referralsData.referrals, id: \.id) { item in
            getRefferalView(item)
        }
        .withHeader(
            title: L10n.ReferralsInfoSheet.headline,
            infoButtonDescription: L10n.ReferralsInfoSheet.body(
                store.state.paymentDiscountsData?.referralsData.discountPerMember
                    .formattedAmount ?? ""
            ),
            withoutBottomPadding: data.referralsData.referrals.isEmpty ? false : true,
            extraView: (
                view: HStack {
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
                .asAnyView,
                alignment: .bottom
            )
        )
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
        .hWithoutHorizontalPadding([.row])
        .dividerInsets(.all, 0)
    }
}

struct PaymentsDiscountView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
        return PaymentsDiscountsView(
            data: .init(
                discounts: [
                    .init(
                        code: "code",
                        amount: .sek(100),
                        title: "title",
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
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
        return PaymentsDiscountsView(
            data: .init(
                discounts: [],
                referralsData: .init(code: "CODE", discountPerMember: .sek(10), discount: .sek(30), referrals: [])
            )
        )
    }
}

struct PaymentsDiscountsRootView: View {
    @PresentableStore var store: PaymentStore
    @StateObject var vm = PaymentsDiscountsRootViewModel()

    var body: some View {
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

@MainActor
class PaymentsDiscountsRootViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
    @PresentableStore var store: PaymentStore
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

struct ReferralView: View {
    let referral: Referral
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: .padding8) {
                Circle().fill(referral.statusColor).frame(width: 14, height: 14)
                VStack(alignment: .leading) {
                    hText(referral.name).foregroundColor(hTextColor.Opaque.primary)
                }
                Spacer()
                hText(referral.discountLabelText).foregroundColor(referral.discountLabelColor)
            }
            if referral.invitedYou {
                HStack(spacing: .padding8) {
                    Circle().fill(Color.clear).frame(width: 14, height: 14)
                    hText(L10n.ReferallsInviteeStates.invitedYou, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
    }
}
