import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimEditSummaryScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var purchasePrice: String = ""

    public init() {}

    public var body: some View {
        hForm {
            hSection(
                header: hText(L10n.Claims.Incident.Screen.header, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            ) {

                displayDateOfIncidentField()
                displayPlaceOfIncidentField()

            }

            hSection(
                header: hText(L10n.Claims.Item.Screen.title, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            ) {
                displayPlaceOfIncidentField()
                displayModelInfoField()
                displayDateOfPurchaseField()
                displayTypeOfDamageField()
            }
        }

        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.dissmissNewClaimFlow)
            } content: {
                hText(L10n.generalSaveButton)
            }
            .padding([.leading, .trailing], 16)
        }
    }

    @ViewBuilder func displayDateOfIncidentField() -> some View {

        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in
            hRow {
                hText(L10n.Claims.Item.Screen.Date.Of.Incident.button)
                    .foregroundColor(hLabelColor.primary)

            }
            .withCustomAccessory {

                Spacer()

                HStack(spacing: 0) {
                    hText(dateOfOccurenceStep?.dateOfOccurence ?? "")
                        .foregroundColor(hLabelColor.primary).colorScheme(.light)
                        .padding([.top, .bottom], 11)
                        .padding([.trailing, .leading], 12)
                }
                .background(hGrayscaleColor.one)
                .cornerRadius(.defaultCornerRadius)
            }
            .onTap {
                store.send(.navigationAction(action: .openDatePicker(type: .setDateOfOccurrence)))
            }
        }
    }

    @ViewBuilder func displayPlaceOfIncidentField() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            hRow {
                HStack {
                    hText(L10n.Claims.Location.Screen.title)
                        .foregroundColor(hLabelColor.primary)
                    Spacer()

                    hText(locationStep?.getSelectedOption()?.displayName ?? "")
                        .foregroundColor(hLabelColor.secondary)
                }
            }
            .onTap {
                store.send(.navigationAction(action: .openLocationPicker))
            }
        }
    }

    @ViewBuilder func displayModelInfoField() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            hRow {
                HStack {
                    hText(L10n.Claims.Item.Screen.Model.button)
                        .foregroundColor(hLabelColor.primary)
                    Spacer()

                    if let getBrandOrModelName = singleItemStep?.getBrandOrModelName() {
                        hText(getBrandOrModelName)
                            .foregroundColor(hLabelColor.secondary)
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
                .foregroundColor(hLabelColor.primary)
        }
        .withCustomAccessory {
            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.singleItemStep
                }
            ) { singleItemStep in
                Spacer()

                HStack(spacing: 0) {
                    if let date = singleItemStep?.purchaseDate {
                        hText(date)
                            .foregroundColor(hLabelColor.primary).colorScheme(.light)
                            .padding([.top, .bottom], 11)
                            .padding([.trailing, .leading], 12)
                    }
                }
                .background(hGrayscaleColor.one)
                .cornerRadius(.defaultCornerRadius)
            }
        }
        .onTap {
            store.send(.navigationAction(action: .openDatePicker(type: .setDateOfPurchase)))
        }

    }

    @ViewBuilder func displayTypeOfDamageField() -> some View {

        hRow {
            HStack {
                hText(L10n.Claims.Item.Screen.Damage.button)
                    .foregroundColor(hLabelColor.primary)

                Spacer()
            }
        }
        .withCustomAccessory {
            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.singleItemStep
                }
            ) { singleItemStep in
                if let text = singleItemStep?.getChoosenDamagesAsText() {
                    hText(text).foregroundColor(hLabelColor.primary)
                } else {
                    hText(L10n.Claim.Location.choose)
                        .foregroundColor(hLabelColor.placeholder)
                }
            }
        }
        .onTap {
            store.send(.navigationAction(action: .openDamagePickerScreen))
        }
    }
}
