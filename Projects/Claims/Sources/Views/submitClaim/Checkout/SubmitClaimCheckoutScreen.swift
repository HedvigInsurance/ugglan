import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimCheckoutScreen: View {
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
                        let repairCost = singleItemCheckoutStep?.compensation.repairCompensation?.repairCost
                        if repairCost == nil {
                            InfoCard(text: L10n.claimsCheckoutNotice, type: .info)
                        }
                        hButton.LargeButton(type: .primary) {
                            store.send(.singleItemCheckoutRequest)
                            store.send(.navigationAction(action: .openCheckoutTransferringScreen))
                        } content: {
                            hText(
                                L10n.Claims.Payout.Button.label(
                                    singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? ""
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
        .claimErrorTrackerFor([.postSingleItemCheckout])
    }

    func getFormContent(from singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        VStack(spacing: 16) {
            hSection {
                VStack(alignment: .center) {
                    hText(
                        singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? "",
                        style: .standardExtraExtraLarge
                    )
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

            let repairCost = singleItemCheckoutStep?.compensation.repairCompensation?.repairCost

            hSection {
                VStack {
                    if let repairCost {
                        PresentableStoreLens(
                            SubmitClaimStore.self,
                            getter: { state in
                                state.singleItemStep
                            }
                        ) { singleItemStep in
                            displayField(
                                withTitle: L10n.claimsCheckoutRepairTitle(singleItemStep?.getBrandOrModelName() ?? ""),
                                andFor: repairCost
                            )
                        }
                    } else {
                        displayField(
                            withTitle: L10n.keyGearItemViewValuationPageTitle,
                            andFor: singleItemCheckoutStep?.compensation.valueCompensation?.price
                        )
                        displayField(
                            withTitle: L10n.Claims.Payout.Age.deduction,
                            andFor: singleItemCheckoutStep?.compensation.valueCompensation?.depreciation.negative
                        )
                    }
                    displayField(
                        withTitle: L10n.Claims.Payout.Age.deductable,
                        andFor: singleItemCheckoutStep?.compensation.deductible.negative
                    )
                }
            }
            .withHeader {
                HStack {
                    hText(L10n.claimsCheckoutCountTitle, style: .body)
                        .foregroundColor(hTextColor.primary)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.claimsCheckoutCountTitle,
                        description: repairCost != nil
                            ? L10n.claimsCheckoutRepairCalculationText : L10n.claimsCheckoutNoRepairCalculationText
                    )
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, 16)

            hSection {
                VStack(spacing: 16) {
                    displayField(
                        withTitle: L10n.claimsPayoutHedvigLabel,
                        useDarkTitle: true,
                        andFor: singleItemCheckoutStep?.compensation.payoutAmount
                    )
                    if repairCost != nil {
                        InfoCard(text: L10n.claimsCheckoutRepairInfoText, type: .info)
                    }
                }
            }
            .sectionContainerStyle(.transparent)

            if repairCost == nil {
                hSection {
                    Divider()
                }
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
                    Spacer()
                    InfoViewHolder(
                        title: L10n.Claims.Payout.Summary.method,
                        description: L10n.claimsCheckoutPayoutText
                    )
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
                .cornerRadius(.defaultCornerRadius)
                .padding(.bottom, 8)
            }
        }
    }
}

struct SubmitClaimCheckoutRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SubmitClaimCheckoutScreen()
            .onAppear {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(
                    .stepModelAction(
                        action: .setSingleItemCheckoutStep(
                            model: .init(
                                id: "id",
                                payoutMethods: [
                                    .init(
                                        id: "id",
                                        autogiro: .init(
                                            id: "autogiroId",
                                            amount: .sek(100),
                                            displayName: "Auto giro"
                                        )
                                    )
                                ],
                                compensation: .init(
                                    id: "compensation id",
                                    deductible: .sek(20),
                                    payoutAmount: .sek(100),
                                    repairCompensation: nil,
                                    valueCompensation: .init(
                                        depreciation: .sek(30),
                                        price: .sek(300)
                                    )
                                )
                            )
                        )
                    )
                )
                store.send(
                    .stepModelAction(
                        action: .setSingleItem(
                            model: .init(
                                id: "Test",
                                availableItemBrandOptions: [],
                                availableItemModelOptions: [
                                    .init(
                                        displayName: "Model display name",
                                        itemBrandId: "testBrand",
                                        itemTypeId: "testModel",
                                        itemModelId: "testModel"
                                    )
                                ],
                                availableItemProblems: [],
                                prefferedCurrency: "sek",
                                currencyCode: "SEK",
                                selectedItemModel: "testModel",
                                defaultItemProblems: []
                            )
                        )
                    )
                )
            }
    }
}

struct SubmitClaimCheckoutNoRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SubmitClaimCheckoutScreen()
            .onAppear {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(
                    .stepModelAction(
                        action: .setSingleItemCheckoutStep(
                            model: .init(
                                id: "id",
                                payoutMethods: [
                                    .init(
                                        id: "id",
                                        autogiro: .init(
                                            id: "autogiroId",
                                            amount: .sek(100),
                                            displayName: "Auto giro"
                                        )
                                    )
                                ],
                                compensation: .init(
                                    id: "compensation id",
                                    deductible: .sek(20),
                                    payoutAmount: .sek(100),
                                    repairCompensation: nil,
                                    valueCompensation: .init(
                                        depreciation: .sek(30),
                                        price: .sek(300)
                                    )
                                )
                            )
                        )
                    )
                )
                store.send(
                    .stepModelAction(
                        action: .setSingleItem(
                            model: .init(
                                id: "Test",
                                availableItemBrandOptions: [],
                                availableItemModelOptions: [
                                    .init(
                                        displayName: "Model display name",
                                        itemBrandId: "testBrand",
                                        itemTypeId: "testModel",
                                        itemModelId: "testModel"
                                    )
                                ],
                                availableItemProblems: [],
                                prefferedCurrency: "sek",
                                currencyCode: "SEK",
                                selectedItemModel: "testModel",
                                defaultItemProblems: []
                            )
                        )
                    )
                )
            }
    }
}
