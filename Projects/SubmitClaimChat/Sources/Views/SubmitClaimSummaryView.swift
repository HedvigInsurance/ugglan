import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSummaryView: View {
    @EnvironmentObject var viewModel: SubmitClaimSummaryStep
    var body: some View {
        VStack(
            spacing: .padding8
        ) {
            VStack(alignment: .leading) {
                hRowDivider()
                    .hWithoutHorizontalPadding([.divider])
            }

            VStack(alignment: .leading, spacing: .padding4) {
                ForEach(viewModel.summaryModel.audioRecordings, id: \.url) { audioPlayer in
                    hSection {
                        TrackPlayerView(audioPlayer: AudioPlayer(url: audioPlayer.url), withoutBackground: true)
                    }
                    .hWithoutHorizontalPadding([.section])
                }

                ForEach(viewModel.summaryModel.items, id: \.title) { item in
                    HStack {
                        hText(item.title, style: .label)
                        Spacer()
                        hText(item.value, style: .label)
                    }
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            hButton(.medium, .primary, content: .init(title: L10n.claimFlowChatSubmitClaimButton)) {
                Task {
                    try await viewModel.submitResponse()
                }
            }
        }
    }
}
