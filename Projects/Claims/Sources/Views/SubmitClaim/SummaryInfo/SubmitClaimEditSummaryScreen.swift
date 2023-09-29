import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimEditSummaryScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var purchasePrice: String = ""

    public init() {}

    public var body: some View {
        hForm {
            hSection(
                header: hText(L10n.Claims.Incident.Screen.header, style: .subheadline)
                    .foregroundColor(hTextColor.secondary)
            ) {

                displayDateOfIncidentField()
                displayPlaceOfIncidentField()

            }

            hSection(
                header: hText(L10n.Claims.Item.Screen.title, style: .subheadline)
                    .foregroundColor(hTextColor.secondary)
            ) {
                displayPlaceOfIncidentField()
                displayModelInfoField()
                displayDateOfPurchaseField()
                displayTypeOfDamageField()
            }
        }

        .hFormAttachToBottom {
            hButton.LargeButton(type: .primary) {
                store.send(.dissmissNewClaimFlow)
            } content: {
                hText(L10n.generalSaveButton)
            }
            .padding([.leading, .trailing], 16)
        }
    }

    @ViewBuilder func displayDateOfIncidentField() -> some View {

        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in
            hRow {
                hText(L10n.Claims.Item.Screen.Date.Of.Incident.button)
                    .foregroundColor(hTextColor.primary)

            }
            .withCustomAccessory {

                Spacer()

                HStack(spacing: 0) {
                    hText(dateOfOccurenceStep?.dateOfOccurence ?? "")
                        .foregroundColor(hTextColor.primary).colorScheme(.light)
                        .padding([.top, .bottom], 11)
                        .padding([.trailing, .leading], 12)
                }
                .background(hGrayscaleColorOld.one)
                .cornerRadius(.defaultCornerRadius)
            }
        }
    }

    @ViewBuilder func displayPlaceOfIncidentField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            hRow {
                HStack {
                    hText(L10n.Claims.Location.Screen.title)
                        .foregroundColor(hTextColor.primary)
                    Spacer()

                    hText(locationStep?.getSelectedOption()?.displayName ?? "")
                        .foregroundColor(hTextColor.secondary)
                }
            }
            .onTap {
                store.send(.navigationAction(action: .openLocationPicker))
            }
        }
    }

    @ViewBuilder func displayModelInfoField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            hRow {
                HStack {
                    hText(L10n.Claims.Item.Screen.Model.button)
                        .foregroundColor(hTextColor.primary)
                    Spacer()

                    if let getBrandOrModelName = singleItemStep?.getBrandOrModelName() {
                        hText(getBrandOrModelName)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
            }
            .onTap {
                store.send(.navigationAction(action: .openModelPicker))
            }
        }

    }

    @ViewBuilder func displayDateOfPurchaseField() -> some View {

        hRow {
            hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                .foregroundColor(hTextColor.primary)
        }
        .withCustomAccessory {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.singleItemStep
                }
            ) { singleItemStep in
                Spacer()

                HStack(spacing: 0) {
                    if let date = singleItemStep?.purchaseDate {
                        hText(date)
                            .foregroundColor(hTextColor.primary).colorScheme(.light)
                            .padding([.top, .bottom], 11)
                            .padding([.trailing, .leading], 12)
                    }
                }
                .background(hGrayscaleColorOld.one)
                .cornerRadius(.defaultCornerRadius)
            }
        }
    }

    @ViewBuilder func displayTypeOfDamageField() -> some View {

        hRow {
            HStack {
                hText(L10n.Claims.Item.Screen.Damage.button)
                    .foregroundColor(hTextColor.primary)

                Spacer()
            }
        }
        .withCustomAccessory {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.singleItemStep
                }
            ) { singleItemStep in
                if let text = singleItemStep?.getChoosenDamagesAsText() {
                    hText(text).foregroundColor(hTextColor.primary)
                } else {
                    hText(L10n.Claim.Location.choose)
                        .foregroundColor(hTextColor.secondary)
                }
            }
        }
        .onTap {
            store.send(.navigationAction(action: .openDamagePickerScreen))
        }
    }
}
