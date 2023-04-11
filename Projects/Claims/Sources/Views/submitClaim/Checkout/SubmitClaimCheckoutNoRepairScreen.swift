import SwiftUI
import hCore
import hCoreUI

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
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.claimNextSingleItemCheckout)
                    store.send(.navigationAction(action: .openCheckoutTransferringScreen))
                } content: {
                    hText(
                        L10n.Claims.Payout.Button.label(
                            singleItemCheckoutStep?.payoutAmount.getAmountWithCurrency() ?? ""
                        ),
                        style: .body
                    )
                    .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding([.leading, .trailing], 16)

            }
        }
    }

    @ViewBuilder
    func displayPriceFields(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        displayField(withTitle: L10n.Claims.Payout.Purchase.price, andFor: checkoutStep?.price)
        Divider()
        displayField(withTitle: L10n.Claims.Payout.Age.deduction, andFor: checkoutStep?.depreciation, prefix: "- ")
        Divider()
        displayField(withTitle: L10n.Claims.Payout.Age.deductable, andFor: checkoutStep?.deductible, prefix: "- ")
        Divider()
        displayField(withTitle: L10n.Claims.Payout.total, andFor: checkoutStep?.payoutAmount)
            .foregroundColor(hLabelColor.primary)
    }

    @ViewBuilder
    func displayField(withTitle title: String, andFor model: ClaimFlowMoneyModel?, prefix: String = "") -> some View {
        hRow {
            HStack {
                hText(title)
                    .foregroundColor(hLabelColor.primary)
                Spacer()

                if checkIfNotDecimal(value: model?.amount ?? 0) {

                    hText(
                        prefix + formatDoubleWithoutDecimal(value: model?.amount ?? 0) + " "
                            + String(model?.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        prefix + formatDoubleWithDecimal(value: model?.amount ?? 0) + " "
                            + String(model?.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                }
            }
        }
        .padding([.leading, .trailing], -20)
    }

    @ViewBuilder

    func displayPaymentMethodField(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        hRow {
            if let payoutMethods = checkoutStep?.payoutMethod {
                ForEach(payoutMethods, id: \.id) { element in
                    hText(element.getDisplayName(), style: .headline)
                        .foregroundColor(hLabelColor.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                }
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(hBackgroundColor.tertiary)
        .cornerRadius(.defaultCornerRadius)
    }

    func checkIfNotDecimal(value: Double) -> Bool {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return true
        }
        return false
    }

    func formatDoubleWithoutDecimal(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(for: value) ?? ""
    }

    func formatDoubleWithDecimal(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter.string(for: value) ?? ""
    }
}

struct SubmitClaimCheckoutNoRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutNoRepairScreen()
    }
}
