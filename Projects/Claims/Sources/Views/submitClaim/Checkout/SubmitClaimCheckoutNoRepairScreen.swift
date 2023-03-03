import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimCheckoutNoRepairScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        hForm {
            hSection {
                hRow {
                    HStack {
                        hText(L10n.Claims.Payout.Purchase.price)
                        Spacer()
                        hText("13 499 kr")
                    }
                }
                .padding([.leading, .trailing], -20)

                hRow {
                    HStack {
                        hText(L10n.Claims.Payout.Age.deduction)
                        Spacer()
                        hText("13 499 kr")
                    }
                }
                .padding([.leading, .trailing], -20)

                hRow {
                    HStack {
                        hText(L10n.Claims.Payout.Age.deductable)
                        Spacer()
                        hText("13 499 kr")
                    }
                }
                .padding([.leading, .trailing], -20)

                hRow {
                    HStack {
                        hText(L10n.Claims.Payout.total)
                        Spacer()
                        hText("13 499 kr")
                    }
                }
                .padding([.leading, .trailing], -20)
            }
            .withHeader {
                hText(L10n.Claims.Payout.Summary.subtitle, style: .title3)
            }
            .sectionContainerStyle(.transparent)

            hSection {
                hRow {
                    hText(L10n.Claims.Payout.Method.autogiro, style: .headline)
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
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
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
}

struct SubmitClaimCheckoutNoRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutNoRepairScreen()
    }
}
