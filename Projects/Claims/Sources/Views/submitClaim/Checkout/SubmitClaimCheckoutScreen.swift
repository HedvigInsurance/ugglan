import StoreContainer
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimCheckoutScreen: View {
    @hPresentableStore var store: SubmitClaimStore

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
                                style: .body1
                            )
                        }
                    }
                }
                .padding(.vertical, .padding16)
                .sectionContainerStyle(.transparent)
            }
        }
        .hPresentableStoreLensAnimation(.spring())
        .claimErrorTrackerFor([.postSingleItemCheckout])
    }

    func getFormContent(from singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?) -> some View {
        VStack(spacing: 16) {
            hSection {
                VStack(alignment: .center) {
                    hText(
                        singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? "",
                        style: .display1
                    )
                    .foregroundColor(hTextColor.Opaque.primary)
                }
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .padding(.vertical, .padding6)
            }
            .padding(.vertical, .padding8)

            let repairCost = singleItemCheckoutStep?.compensation.repairCompensation?.repairCost

            hSection {
                VStack {
                    if let repairCost {
                        displayField(
                            withTitle: L10n.claimsCheckoutRepairTitle(
                                singleItemCheckoutStep?.singleItemModel?.getBrandOrModelName() ?? ""
                            ),
                            andFor: repairCost
                        )
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
                    hText(L10n.claimsCheckoutCountTitle, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.claimsCheckoutCountTitle,
                        description: repairCost != nil
                            ? L10n.claimsCheckoutRepairCalculationText : L10n.claimsCheckoutNoRepairCalculationText
                    )
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)

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
                                hText(element.getDisplayName(), style: .heading2)
                                    .foregroundColor(hTextColor.Opaque.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .withSelectedAccessory(
                                checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark
                            )
                            .noSpacing()
                            .padding(.vertical, .padding8)
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
                    hText(L10n.Claims.Payout.Summary.method, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
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
                    hText(title, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                } else {
                    hText(title, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                Spacer()

                hText(
                    model?.formattedAmount ?? "",
                    style: .body1
                )
                .foregroundColor(hTextColor.Opaque.secondary)
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
                    hText(element.getDisplayName(), style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, .padding4)
                }
                .withSelectedAccessory(checkoutStep.selectedPayoutMethod == element && shouldShowCheckmark)
                .cornerRadius(.cornerRadiusL)
                .padding(.bottom, .padding8)
            }
        }
    }
}

struct SubmitClaimCheckoutRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return SubmitClaimCheckoutScreen()
            .onAppear {
                let store: SubmitClaimStore = hGlobalPresentableStoreContainer.get()
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
                                ),
                                singleItemModel: nil
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
                                defaultItemProblems: [],
                                purchasePriceApplicable: false
                            )
                        )
                    )
                )
            }
    }
}

struct SubmitClaimCheckoutNoRepairScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return SubmitClaimCheckoutScreen()
            .onAppear {
                let store: SubmitClaimStore = hGlobalPresentableStoreContainer.get()
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
                                ),
                                singleItemModel: nil
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
                                defaultItemProblems: [],
                                purchasePriceApplicable: false
                            )
                        )
                    )
                )
            }
    }
}
