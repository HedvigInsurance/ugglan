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
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                hTextNew("Trasig telefon", style: .body)
                                    .foregroundColor(hLabelColorNew.primary)
                                hTextNew("Anmäld 2023.02.31", style: .body)
                                    .foregroundColor(hLabelColorNew.secondary)
                            }
                        }

                        .padding([.leading, .trailing, .top], 16)

                        HStack {
                            VStack {
                                Rectangle()
                                    .fill(hAmberColorNew.amber600)
                                    .frame(height: 4)
                                hText("Anmäld", style: .caption1)
                                    .foregroundColor(hLabelColorNew.primary)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                Rectangle()
                                    .fill(hGrayscaleColorNew.greyScale400)
                                    .frame(height: 4)
                                hText("Hanteras", style: .caption1)
                                    .foregroundColor(hGrayscaleColorNew.greyScale400)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                Rectangle()
                                    .fill(hGrayscaleColorNew.greyScale400)
                                    .frame(height: 4)
                                hText("Avslutad", style: .caption1)
                                    .foregroundColor(hGrayscaleColorNew.greyScale400)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding([.leading, .trailing], 16)

                        displayExpandedView()
                    }

                }
                .sectionContainerStyle(.opaque(useNewDesign: true))
            }
            .hFormTitle(.small, L10n.claimsCheckInformationTitle)
            .hUseNewStyle
            .hFormAttachToBottom {
                VStack {
                    NoticeComponent(text: L10n.claimsComplementClaim)

                    hButton.LargeButtonFilled {
                        store.send(.summaryRequest)
                    } content: {
                        hText(L10n.embarkSubmitClaim)
                    }
                    .padding([.leading, .trailing], 16)
                }
            }
        }
    }

    private func displayExpandedView() -> some View {
        VStack {
            displayTitleField()
            displayModelField()
            displayDateOfPurchase()
            displayPurchasePriceField()
            displayDateOfOccurrenceField()
            displayPlaceOfOccurrenceField()
            displayDamageField()

            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.audioRecordingStep
                }
            ) { audioRecordingStep in
                let audioPlayer = AudioPlayer(url: audioRecordingStep?.getUrl())
                TrackPlayer(audioPlayer: audioPlayer)
                    .hUseNewStyle
                    .hWithoutFootnote
            }

        }
        .padding(.bottom, 24)
        .padding(.horizontal, 16)
        .foregroundColor(hLabelColorNew.secondary)
    }

    @ViewBuilder func displayTitleField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.summaryStep
            }
        ) { summaryStep in
            HStack {
                hTextNew("Ärende", style: .body)
                Spacer()
                hTextNew(summaryStep?.title ?? "", style: .body)
                    .padding(.trailing, 14)
            }
        }
    }

    @ViewBuilder func displayDateOfOccurrenceField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.dateOfOccurenceStep
            }
        ) { dateOfOccurenceStep in
            HStack {
                hTextNew("Skadedatum:", style: .body)
                Spacer()
                hTextNew(dateOfOccurenceStep?.dateOfOccurence ?? "", style: .body)
                    .padding(.trailing, 14)
            }
        }
    }

    @ViewBuilder func displayPlaceOfOccurrenceField() -> some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.locationStep
            }
        ) { locationStep in
            HStack {
                hTextNew("Plats:", style: .body)
                Spacer()
                hTextNew(locationStep?.getSelectedOption()?.displayName ?? "", style: .body)
                    .padding(.trailing, 14)
            }
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

            HStack {
                hTextNew(L10n.Claims.Payout.Purchase.price, style: .body)
                Spacer()
                hTextNew(stringToDisplay ?? "", style: .body)
                    .padding(.trailing, 14)
            }
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
                HStack {
                    hTextNew("Modell:", style: .body)
                    Spacer()
                    hTextNew(modelName, style: .body)
                        .padding(.trailing, 14)
                }
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

            HStack {
                hTextNew("Inköpsdatum:", style: .body)
                Spacer()
                hTextNew(stringToDisplay ?? "", style: .body)
                    .padding(.trailing, 14)
            }
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
                HStack {
                    hTextNew("Skador:", style: .body)
                    Spacer()
                    hTextNew(L10n.summarySelectedProblemDescription(chosenDamages), style: .body)
                        .padding(.trailing, 14)
                }
            }
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
