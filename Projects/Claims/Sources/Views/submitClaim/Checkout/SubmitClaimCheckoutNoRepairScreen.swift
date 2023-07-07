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
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack(spacing: 8) {
                    InfoCard(text: L10n.claimsCheckoutNotice, type: .info)
                        .padding(.bottom, 8)

                    hButton.LargeButtonFilled {
                        store.send(.singleItemCheckoutRequest)
                        store.send(.navigationAction(action: .openCheckoutTransferringScreen))
                    } content: {
                        hTextNew(
                            L10n.Claims.Payout.Button.label(
                                singleItemCheckoutStep?.payoutAmount.formattedAmount ?? ""
                            ),
                            style: .body
                        )
                    }
                    .padding(.horizontal, 16)

                    hButton.LargeButtonText {
                        store.send(.navigationAction(action: .dismissScreen))
                    } content: {
                        hTextNew(
                            L10n.generalBackButton,
                            style: .body
                        )
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .presentableStoreLensAnimation(.spring())
    }

    func getFormContent(from singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        VStack(spacing: 16) {
            hSection {
                VStack(alignment: .center) {
                    hTextNew(singleItemCheckoutStep?.payoutAmount.formattedAmount ?? "", style: .title1)
                        .foregroundColor(hTextColorNew.primary)
                }
                .background(
                    Squircle.default()
                        .fill(Color.clear)
                )
                .padding(.vertical, 6)
            }
            .withHeader {
                hTextNew(L10n.Claims.Payout.Summary.subtitle, style: .body)
                    .foregroundColor(hTextColorNew.primary)
                    .padding(.top, 16)
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
                    hTextNew(L10n.claimsCheckoutCountTitle, style: .body)
                        .foregroundColor(hTextColorNew.primary)
                }
            }
            .sectionContainerStyle(.transparent)

            Divider()
                .padding(.horizontal, 16)

            hSection {
                if let checkoutStep = singleItemCheckoutStep {
                    let payoutMethods = checkoutStep.payoutMethods
                    let shouldShowCheckmark = payoutMethods.count > 1
                    ForEach(payoutMethods, id: \.id) { element in
                        hRow {
                            hTextNew(element.getDisplayName(), style: .title3)
                                .foregroundColor(hTextColorNew.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .withSelectedAccessory(
                            checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark
                        )
                        .noSpacing()
                        .padding(.vertical, 9)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            withAnimation {
                                store.send(.setPayoutMethod(method: element))
                            }
                        }
                    }
                }
            }
            .withHeader {
                HStack {
                    hTextNew(L10n.Claims.Payout.Summary.method, style: .body)
                        .foregroundColor(hTextColorNew.primary)
                }
            }
        }
    }

    @ViewBuilder
    func displayField(withTitle title: String, andFor model: MonetaryAmount?) -> some View {
        hRow {
            HStack {
                hTextNew(title, style: .body)
                    .foregroundColor(hTextColorNew.secondary)
                Spacer()

                hTextNew(
                    model?.formattedAmount ?? "",
                    style: .body
                )
                .foregroundColor(hTextColorNew.secondary)
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
                        .foregroundColor(hLabelColor.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                }
                .withSelectedAccessory(checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark)
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
