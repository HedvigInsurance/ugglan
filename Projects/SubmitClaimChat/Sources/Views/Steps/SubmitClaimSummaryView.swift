import Claims
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSummaryView: View {
    @ObservedObject var viewModel: SubmitClaimSummaryStep

    var body: some View {
        hSection {
            hRow {
                VStack(
                    alignment: .leading,
                    spacing: .padding24
                ) {
                    itemView
                    audioRecordingView
                    freeTextsView
                    uploadedFilesView
                }
            }
        }
        .sectionContainerStyle(.negative)
        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
        .hWithoutHorizontalPadding([.section])
        .overlay {
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .inset(by: 0.5)
                .stroke(hBorderColor.primary, lineWidth: 1)
        }
    }

    @ViewBuilder
    var itemView: some View {
        if viewModel.summaryModel.items.count != 0 {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(L10n.ClaimStatus.ClaimDetails.title)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    ForEach(viewModel.summaryModel.items, id: \.title) { item in
                        HStack {
                            hText(item.title)
                            Spacer()
                            hText(item.value)
                        }
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.title): \(item.value.getAccessibilityLabelDate)")
                    }
                }
            }
        }
    }

    @ViewBuilder
    var audioRecordingView: some View {
        if viewModel.summaryModel.audioRecordings.count != 0 {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(L10n.claimChatRecordingTitle)
                    .accessibilityAddTraits(.isHeader)
                ForEach(viewModel.summaryModel.audioRecordings, id: \.url) { audioPlayer in
                    hSection {
                        TrackPlayerView(audioPlayer: AudioPlayer(url: audioPlayer.url))
                    }
                    .hWithoutHorizontalPadding([.section])
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var uploadedFilesView: some View {
        if !viewModel.summaryModel.fileUploads.isEmpty {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(L10n.claimChatFileTitle)
                    .accessibilityAddTraits(.isHeader)
                FilesGridView(vm: viewModel.fileGridViewModel)
                    .hFileGridAlignment(alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var freeTextsView: some View {
        if !viewModel.summaryModel.freeTexts.isEmpty {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(L10n.claimChatOtherTitle)
                    .accessibilityAddTraits(.isHeader)
                ForEach(viewModel.summaryModel.freeTexts, id: \.self) { freeText in
                    HStack {
                        hText(freeText)
                        Spacer()
                    }
                    .hPillStyle(color: .grey, colorLevel: .two, withBorder: false)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(freeText)
                }
                .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }
}

struct SubmitClaimSummaryBottomView: View {
    @ObservedObject var viewModel: SubmitClaimSummaryStep

    var body: some View {
        hSection {
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.claimChatSubmitClaim)
            ) {
                viewModel.submitResponse()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let vm = SubmitClaimSummaryStep(
        claimIntent: .init(
            currentStep: .init(
                content: .summary(
                    model: .init(
                        audioRecordings: [
                            .init(url: URL(string: "https://hedvig.com")!)
                        ],
                        fileUploads: [],
                        items: [
                            .init(title: "Date", value: "2025-11-25"),
                            .init(title: "Location", value: "At home"),
                            .init(title: "Type", value: "Phone"),
                            .init(title: "Brand", value: "iPhone"),
                            .init(title: "Model", value: "iPhone 14 Pro"),
                            .init(title: "Purchase date", value: "2023-11-26"),
                        ],
                        freeTexts: [
                            """
                            It is a long 
                            text
                            that goes in more lines
                            and should take full width
                            """,
                            """
                            One long text that should be shown nicely in the view and take full width of the screen
                            """,
                        ]
                    )
                ),
                id: "id1",
                text: "text"
            ),
            id: "claimIntentId",
            isSkippable: false,
            isRegrettable: false,
            progress: 0
        ),
        service: .init(),
        mainHandler: { _ in }
    )
    return hForm {
        hSection {
            SubmitClaimSummaryView(viewModel: vm)
        }
    }
}

@MainActor
extension String {
    var getAccessibilityLabelDate: String {
        self.localDateToDate?.displayDateDDMMMYYYYFormat ?? self
    }
}
