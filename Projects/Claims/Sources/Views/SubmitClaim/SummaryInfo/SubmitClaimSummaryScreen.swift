import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        LoadingViewWithContent(.postSummary) {
            hForm {
                VStack(alignment: .center) {

                    displayTitleField()
                    displayDateAndLocationOfOccurrenceField()
                    displayModelField()
                    displayDateOfPurchase()
                    displayDamageField()
                }
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.claimNextSummary)
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .padding([.leading, .trailing], 16)
            }

        }
    }

    @ViewBuilder func displayTitleField() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.summaryStep
            }
        ) { summaryStep in
            hText(summaryStep?.title ?? "", style: .title3)
                .padding(.top, UIScreen.main.bounds.size.height / 5)
                .foregroundColor(hLabelColor.secondary)
        }
    }

    @ViewBuilder func displayDateAndLocationOfOccurrenceField() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in
            HStack {
                Image(uiImage: hCoreUIAssets.calendar.image)
                    .resizable()
                    .frame(width: 12.0, height: 12.0)
                    .foregroundColor(.secondary)
                hText(dateOfOccurenceStep?.dateOfOccurence ?? L10n.Claims.Summary.Screen.Not.selected)
                    .padding(.top, 1)
                    .foregroundColor(.secondary)
            }
        }
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            HStack {
                Image(uiImage: hCoreUIAssets.location.image)
                    .foregroundColor(hLabelColor.secondary)
                hText(locationStep?.getSelectedOption()?.displayName ?? L10n.Claims.Summary.Screen.Not.selected)
                    .padding(.top, 1)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder func displayModelField() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            if let modelName = singleItemStep?.getBrandOrModelName() {
                hText(modelName)
                    .padding(.top, 40)
                    .foregroundColor(hLabelColor.primary)
            }
        }
    }

    @ViewBuilder func displayDateOfPurchase() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in

            let stringToDisplay = singleItemStep?.returnDisplayStringForSummary

            hText(stringToDisplay ?? L10n.Claims.Summary.Screen.Not.selected)
                .padding(.top, 1)
                .foregroundColor(hLabelColor.primary)
        }
    }

    @ViewBuilder func displayDamageField() -> some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.singleItemStep
            }
        ) { singleItemStep in
            if let chosenDamages = singleItemStep?.getChoosenDamagesAsText() {
                hText(L10n.summarySelectedProblemDescription(chosenDamages)).foregroundColor(hLabelColor.primary)
                    .padding(.top, 1)
            }
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
