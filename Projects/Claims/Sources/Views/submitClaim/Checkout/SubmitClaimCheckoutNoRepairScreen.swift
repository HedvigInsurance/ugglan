import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimCheckoutNoRepairScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        hForm {

            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.singleItemCheckoutStep
                }
            ) { singleItemCheckoutStep in

                hSection {
                    displayPriceFields(checkoutStep: singleItemCheckoutStep)
                }
                .withHeader {
                    hText(L10n.Claims.Payout.Summary.subtitle, style: .title3)
                        .foregroundColor(hLabelColor.primary)
                }
                .sectionContainerStyle(.transparent)

                hSection {
                    hRow {
                        hText(L10n.Claims.Payout.Method.autogiro, style: .headline)
                            .foregroundColor(hLabelColor.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 4)

                    }
                    .frame(height: 64)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(hBackgroundColor.tertiary)
                    .cornerRadius(.defaultCornerRadius)

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
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.navigationAction(action: .openCheckoutTransferringScreen))
            } content: {
                hText(L10n.Claims.Payout.Payout.label, style: .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding([.leading, .trailing], 16)

        }
    }

    @ViewBuilder func displayPriceFields(checkoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        hRow {
            HStack {
                hText(L10n.Claims.Payout.Purchase.price)
                    .foregroundColor(hLabelColor.primary)
                Spacer()

                if checkIfNotDecimal(value: checkoutStep?.price.amount ?? 0) {

                    hText(
                        formatDoubleWithoutDecimal(value: checkoutStep?.price.amount ?? 0) + " "
                            + String(checkoutStep?.price.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        formatDoubleWithDecimal(value: checkoutStep?.payoutAmount.amount ?? 0) + " "
                            + String(checkoutStep?.payoutAmount.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                }
            }
        }
        .padding([.leading, .trailing], -20)

        hRow {
            HStack {
                hText(L10n.Claims.Payout.Age.deduction)
                    .foregroundColor(hLabelColor.primary)
                Spacer()

                if checkIfNotDecimal(value: checkoutStep?.deductible.amount ?? 0) {

                    hText(
                        "- " + formatDoubleWithoutDecimal(value: checkoutStep?.deductible.amount ?? 0.0) + " "
                            + String(checkoutStep?.deductible.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        "- " + String(checkoutStep?.depreciation.amount ?? 0) + " "
                            + String(checkoutStep?.depreciation.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                }
            }
        }
        .padding([.leading, .trailing], -20)

        hRow {
            HStack {
                hText(L10n.Claims.Payout.Age.deductable)
                    .foregroundColor(hLabelColor.primary)
                Spacer()

                if checkIfNotDecimal(value: checkoutStep?.deductible.amount ?? 0) {
                    hText(
                        "- " + formatDoubleWithoutDecimal(value: checkoutStep?.deductible.amount ?? 0) + " "
                            + String(checkoutStep?.deductible.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        "- " + String(checkoutStep?.deductible.amount ?? 0) + " "
                            + String(checkoutStep?.deductible.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                }
            }
        }
        .padding([.leading, .trailing], -20)

        hRow {
            HStack {
                hText(L10n.Claims.Payout.total)
                    .foregroundColor(hLabelColor.primary)
                Spacer()
                if checkIfNotDecimal(value: checkoutStep?.price.amount ?? 0) {
                    hText(
                        formatDoubleWithoutDecimal(value: checkoutStep?.price.amount ?? 0.0) + " "
                            + String(checkoutStep?.price.currencyCode ?? "")
                    )
                } else {
                    hText(
                        String(checkoutStep?.price.amount ?? 0) + " " + String(checkoutStep?.price.currencyCode ?? "")
                    )
                }
            }
        }
        .padding([.leading, .trailing], -20)
        .foregroundColor(hLabelColor.secondary)
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
