import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatSuccessScreen: View {
    let summaryModel: ClaimIntentStepContentSummary
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @EnvironmentObject var router: Router

    public var body: some View {

        hSection {
            VStack(spacing: .padding8) {
                hCoreUIAssets.checkmarkFilled.view
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(hSignalColor.Green.element)
                    .accessibilityHidden(true)

                VStack(alignment: .center, spacing: .padding16) {
                    hText("Your claim was submitted")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: .padding4) {
                        audioRecordingView
                        itemView
                    }
                }
                .padding(.horizontal, .padding56)

                .accessibilityElement(children: .combine)

                hButton(
                    .medium,
                    .primary,
                    content: .init(title: L10n.generalDoneButton),
                    {
                        router.dismiss(withDismissingAll: true)
                    }
                )
                .padding(.top, .padding8)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var audioRecordingView: some View {
        ForEach(summaryModel.audioRecordings, id: \.url) { url in
            hSection {
                SubmitClaimChatAudioRecorder(viewModel: viewModel, uploadURI: "")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .hWithoutHorizontalPadding([.section])
        }
    }

    private var itemView: some View {
        ForEach(summaryModel.items, id: \.title) { item in
            HStack {
                hText(item.title, style: .label)
                Spacer()
                hText(item.value, style: .label)
            }
            .foregroundColor(hTextColor.Opaque.secondary)
        }
    }
}

#Preview {
    SubmitClaimChatSuccessScreen(
        summaryModel: .init(
            audioRecordings: [],
            fileUploads: [],
            items: [
                .init(title: "title1", value: "value1"),
                .init(title: "title2", value: "value2"),
                .init(title: "title3", value: "value3"),
            ]
        )
    )
}
