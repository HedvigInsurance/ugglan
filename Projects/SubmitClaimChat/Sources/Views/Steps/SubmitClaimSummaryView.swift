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
                }
            }
        }
        .sectionContainerStyle(.white)
        .hWithoutHorizontalPadding([.section])
    }

    @ViewBuilder
    var itemView: some View {
        if viewModel.summaryModel.items.count != 0 {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(L10n.ClaimStatus.ClaimDetails.title)
                VStack {
                    ForEach(viewModel.summaryModel.items, id: \.title) { item in
                        HStack {
                            hText(item.title)
                            Spacer()
                            hText(item.value)
                        }
                        .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var audioRecordingView: some View {
        if viewModel.summaryModel.audioRecordings.count != 0 {
            VStack(alignment: .leading, spacing: .padding8) {
                hText("Recording")
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
}

struct SubmitClaimSummaryBottomView: View {
    @ObservedObject var viewModel: SubmitClaimSummaryStep

    var body: some View {
        hSection {
            hButton(
                .large,
                .primary,
                content: .init(title: "Submit your claim")
            ) {
                Task {
                    await viewModel.submitResponse()
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
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
                        ]
                    )
                ),
                id: "id1",
                text: "text"
            ),
            id: "claimIntentId",
            isSkippable: false,
            isRegrettable: false
        ),
        service: .init(),
        mainHandler: { _ in }
    )
    SubmitClaimSummaryView(viewModel: vm)
}
