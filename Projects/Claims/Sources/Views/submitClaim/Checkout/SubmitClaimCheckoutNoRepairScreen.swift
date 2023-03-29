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
                    state.newClaim
                }
            ) { claim in

                hSection {
                    displayPriceFields(claim: claim)
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
                store.send(.openCheckoutTransferringScreen)
            } content: {
                hText(L10n.Claims.Payout.Payout.label, style: .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding([.leading, .trailing], 16)

        }
    }

    @ViewBuilder func displayPriceFields(claim: NewClaim) -> some View {
        hRow {
            HStack {
                hText(L10n.Claims.Payout.Purchase.price)
                    .foregroundColor(hLabelColor.primary)
                Spacer()

                if checkIfNotDecimal(value: claim.priceOfPurchase?.amount ?? 0) {

                    hText(
                        formatDoubleWithoutDecimal(value: claim.priceOfPurchase?.amount ?? 0) + " "
                            + String(claim.payoutAmount?.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        formatDoubleWithDecimal(value: claim.priceOfPurchase?.amount ?? 0) + " "
                            + String(claim.payoutAmount?.currencyCode ?? "")
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

                if checkIfNotDecimal(value: claim.priceOfPurchase?.amount ?? 0) {

                    hText(
                        "- " + formatDoubleWithoutDecimal(value: claim.depreciation?.amount ?? 0.0) + " "
                            + String(claim.deductible?.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        "- " + String(claim.depreciation?.amount ?? 0) + " "
                            + String(claim.deductible?.currencyCode ?? "")
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

                if checkIfNotDecimal(value: claim.priceOfPurchase?.amount ?? 0) {
                    hText(
                        "- " + formatDoubleWithoutDecimal(value: claim.deductible?.amount ?? 0) + " "
                            + String(claim.payoutAmount?.currencyCode ?? "")
                    )
                    .foregroundColor(hLabelColor.secondary)
                } else {
                    hText(
                        "- " + String(claim.deductible?.amount ?? 0) + " "
                            + String(claim.depreciation?.currencyCode ?? "")
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
                if checkIfNotDecimal(value: claim.priceOfPurchase?.amount ?? 0) {
                    hText(
                        formatDoubleWithoutDecimal(value: claim.payoutAmount?.amount ?? 0.0) + " "
                            + String(claim.payoutAmount?.currencyCode ?? "")
                    )
                } else {
                    hText(
                        String(claim.payoutAmount?.amount ?? 0) + " " + String(claim.payoutAmount?.currencyCode ?? "")
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
