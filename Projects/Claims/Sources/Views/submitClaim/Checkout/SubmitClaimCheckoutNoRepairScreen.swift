import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimCheckoutNoRepairScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemCheckoutStep
            }
        ) { singleItemCheckoutStep in
            hForm {
                getFormContent(from: singleItemCheckoutStep)
            }
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 16) {
                        InfoCard(text: L10n.claimsCheckoutNotice, type: .info)
                        hButton.LargeButton(type: .primary) {
                            store.send(.singleItemCheckoutRequest)
                            store.send(.navigationAction(action: .openCheckoutTransferringScreen))
                        } content: {
                            hText(
                                L10n.Claims.Payout.Button.label(
                                    singleItemCheckoutStep?.payoutAmount.formattedAmount ?? ""
                                ),
                                style: .body
                            )
                        }
                    }
                }
                .padding(.vertical, 16)
                .sectionContainerStyle(.transparent)
            }
        }
        .presentableStoreLensAnimation(.spring())
    }

    func getFormContent(from singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        VStack(spacing: 16) {
            hSection {
                VStack(alignment: .center) {
                    hText(singleItemCheckoutStep?.payoutAmount.formattedAmount ?? "", style: .title1)
                        .foregroundColor(hTextColor.primary)
                }
                .background(
                    Squircle.default()
                        .fill(Color.clear)
                )
                .padding(.vertical, 6)
            }
            .withHeader {
                hText(L10n.Claims.Payout.Summary.subtitle, style: .body)
                    .foregroundColor(hTextColor.primary)
                    .padding(.top, 8)
            }
            .padding(.bottom, 8)

            hSection {
                displayField(
                    withTitle: L10n.keyGearItemViewValuationPageTitle,
                    andFor: singleItemCheckoutStep?.price
                )
                displayField(
                    withTitle: L10n.Claims.Payout.Age.deduction,
                    andFor: singleItemCheckoutStep?.depreciation.negative
                )
                displayField(
                    withTitle: L10n.Claims.Payout.Age.deductable,
                    andFor: singleItemCheckoutStep?.deductible.negative
                )
            }
            .withHeader {
                HStack {
                    hText(L10n.claimsCheckoutCountTitle, style: .body)
                        .foregroundColor(hTextColor.primary)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, 16)

            hSection {
                displayField(
                    withTitle: L10n.claimsPayoutHedvigLabel,
                    useDarkTitle: true,
                    andFor: singleItemCheckoutStep?.payoutAmount
                )
            }
            .sectionContainerStyle(.transparent)

            hSection {
                Divider()
            }

            hSection {
                if let checkoutStep = singleItemCheckoutStep {
                    let payoutMethods = checkoutStep.payoutMethods
                    let shouldShowCheckmark = payoutMethods.count > 1
                    ForEach(payoutMethods, id: \.id) { element in
                        hSection {
                            hRow {
                                hText(element.getDisplayName(), style: .title3)
                                    .foregroundColor(hTextColor.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .withSelectedAccessory(
                                checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark
                            )
                            .noSpacing()
                            .padding(.vertical, 9)
                            .onTapGesture {
                                withAnimation {
                                    store.send(.setPayoutMethod(method: element))
                                }
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                }
            }
            .withHeader {
                HStack {
                    hText(L10n.Claims.Payout.Summary.method, style: .body)
                        .foregroundColor(hTextColor.primary)
                }
            }
        }
    }

    @ViewBuilder
    func displayField(withTitle title: String, useDarkTitle: Bool = false, andFor model: MonetaryAmount?) -> some View {
        hRow {
            HStack {
                if useDarkTitle {
                    hText(title, style: .body)
                        .foregroundColor(hTextColor.primary)
                } else {
                    hText(title, style: .body)
                        .foregroundColor(hTextColor.secondary)
                }
                Spacer()

                hText(
                    model?.formattedAmount ?? "",
                    style: .body
                )
                .foregroundColor(hTextColor.secondary)
            }
        }
        .noSpacing()
        .hWithoutDivider
    }

    @ViewBuilder

    func displayPaymentMethodField(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {

        if let checkoutStep = checkoutStep {
            let payoutMethods = checkoutStep.payoutMethods
            let shouldShowCheckmark = payoutMethods.count > 1
            ForEach(payoutMethods, id: \.id) { element in
                hRow {
                    hText(element.getDisplayName(), style: .headline)
                        .foregroundColor(hTextColor.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                }
                .withSelectedAccessory(checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark)
                //                .background(hBackgroundColor.tertiary)
                .cornerRadius(.defaultCornerRadius)
                .padding(.bottom, 8)
            }
        }
    }
}

struct SubmitClaimCheckoutNoRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutNoRepairScreen()
    }
}
