import Kingfisher
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        LoadingViewWithContent(.postSummary) {
            hForm {
                hSection {
                    VStack {
                        hRow {
                            hTextNew(L10n.changeAddressDetails, style: .body)
                                .foregroundColor(hLabelColorNew.primary)
                            Spacer()
                            Image(uiImage: hCoreUIAssets.infoSmall.image)
                                .foregroundColor(hLabelColor.secondary)
                        }
                        .verticalPadding(0)
                        .padding(.bottom, 8)
                        .padding(.top, 16)
                        VStack(spacing: 2) {
                            displayTitleField()
                            displayDamageField()
                            displayDateOfOccurrenceField()
                            displayPlaceOfOccurrenceField()
                            displayModelField()
                            displayDateOfPurchase()
                            displayPurchasePriceField()
                        }
                        .foregroundColor(hLabelColorNew.secondary)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack {
                    NoticeComponent(text: L10n.claimsComplementClaim)

                    Group {
                        hButton.LargeButtonFilled {
                            store.send(.summaryRequest)
                        } content: {
                            hTextNew(L10n.embarkSubmitClaim, style: .body)
                        }

                        hButton.LargeButtonText {
                            store.send(.navigationAction(action: .dismissScreen))
                        } content: {
                            hTextNew(L10n.embarkGoBackButton, style: .body)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    @ViewBuilder func displayRow(leftTitle: String, rightTitle: String) -> some View {
        hRow {
            hTextNew(leftTitle, style: .body)
            Spacer()
            hTextNew(rightTitle, style: .body)
        }
        .verticalPadding(0)
    }

    @ViewBuilder func displayTitleField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.summaryStep
            }
        ) { summaryStep in
            displayRow(leftTitle: L10n.claimsCase, rightTitle: summaryStep?.title ?? "")
        }
    }

    @ViewBuilder func displayDateOfOccurrenceField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in
            displayRow(
                leftTitle: L10n.Claims.Item.Screen.Date.Of.Incident.button,
                rightTitle: dateOfOccurenceStep?.dateOfOccurence ?? ""
            )
        }
    }

    @ViewBuilder func displayPlaceOfOccurrenceField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            displayRow(
                leftTitle: L10n.Claims.Location.Screen.title,
                rightTitle: locationStep?.getSelectedOption()?.displayName ?? ""
            )
        }
    }

    @ViewBuilder func displayPurchasePriceField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in

            let stringToDisplay = singleItemStep?.returnDisplayStringForSummaryPrice
            displayRow(leftTitle: L10n.Claims.Payout.Purchase.price, rightTitle: stringToDisplay ?? "")
        }
    }

    @ViewBuilder func displayModelField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            if let modelName = singleItemStep?.getBrandOrModelName() {
                displayRow(leftTitle: L10n.Claims.Item.Screen.Model.button, rightTitle: modelName)
            }
        }
    }

    @ViewBuilder func displayDateOfPurchase() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in

            let stringToDisplay = singleItemStep?.returnDisplayStringForSummaryDate
            displayRow(
                leftTitle: L10n.Claims.Item.Screen.Date.Of.Purchase.button,
                rightTitle: stringToDisplay ?? ""
            )
        }
    }

    @ViewBuilder func displayDamageField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            if let chosenDamages = singleItemStep?.getChoosenDamagesAsText() {
                displayRow(
                    leftTitle: L10n.claimsDamages,
                    rightTitle: L10n.summarySelectedProblemDescription(chosenDamages)
                )
            }
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
