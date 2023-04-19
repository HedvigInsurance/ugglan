import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimCheckoutNoRepairScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.singleItemCheckoutStep
            }
        ) { singleItemCheckoutStep in
            hForm {
                hSection {
                    displayPriceFields(checkoutStep: singleItemCheckoutStep)
                }
                .withHeader {
                    hText(L10n.Claims.Payout.Summary.subtitle, style: .title3)
                        .foregroundColor(hLabelColor.primary)
                }
                .sectionContainerStyle(.transparent)

                hSection {
                    displayPaymentMethodField(checkoutStep: singleItemCheckoutStep)
                }
                .withHeader {
                    HStack(spacing: 0) {
                        hText(L10n.Claims.Payout.Summary.method, style: .title3)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                }
                .sectionContainerStyle(.transparent)
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.claimNextSingleItemCheckout)
                    store.send(.navigationAction(action: .openCheckoutTransferringScreen))
                } content: {
                    hText(
                        L10n.Claims.Payout.Button.label(
                            singleItemCheckoutStep?.payoutAmount.formattedAmount ?? ""
                        ),
                        style: .body
                    )
                    .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)
            }
        }
        .presentableStoreLensAnimation(.spring())
    }

    @ViewBuilder
    func displayPriceFields(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        displayField(withTitle: L10n.Claims.Payout.Purchase.price, andFor: checkoutStep?.price)
        Divider()
        displayField(withTitle: L10n.Claims.Payout.Age.deduction, andFor: checkoutStep?.depreciation.negative)
        Divider()
        displayField(withTitle: L10n.Claims.Payout.Age.deductable, andFor: checkoutStep?.deductible.negative)
        Divider()
        displayField(withTitle: L10n.Claims.Payout.total, andFor: checkoutStep?.payoutAmount)
            .foregroundColor(hLabelColor.primary)
    }

    @ViewBuilder
    func displayField(withTitle title: String, andFor model: MonetaryAmount?) -> some View {
        hRow {
            HStack {
                hText(title)
                    .foregroundColor(hLabelColor.primary)
                Spacer()

                hText(
                    model?.formattedAmount ?? ""
                )
                .foregroundColor(hLabelColor.secondary)
            }
        }
        .padding([.leading, .trailing], -20)
    }

    @ViewBuilder

    func displayPaymentMethodField(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {

        if let checkoutStep = checkoutStep {
            let payoutMethods = checkoutStep.payoutMethods
            let shouldShowCheckmark = payoutMethods.count > 1
            ForEach(payoutMethods, id: \.id) { element in
                hRow {
                    hText(element.getDisplayName(), style: .headline)
                        .foregroundColor(hLabelColor.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                }
                .withSelectedAccessory(checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark)
                .onTapGesture {
                    withAnimation {
                        store.send(.setPayoutMethod(method: element))
                    }
                }
                .background(hBackgroundColor.tertiary)
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
