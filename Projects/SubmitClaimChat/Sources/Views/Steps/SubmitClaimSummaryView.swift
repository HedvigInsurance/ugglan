import Claims
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSummaryView: View {
    @ObservedObject var viewModel: SubmitClaimSummaryStep
    @State private var showAllAnswers = false

    private var claimDetails: [ClaimIntentStepContentSummary.ClaimIntentStepContentSummaryItem] {
        viewModel.summaryModel.keyDetails.isEmpty
            ? viewModel.summaryModel.items
            : viewModel.summaryModel.keyDetails
    }

    var body: some View {
        hSection {
            hRow {
                VStack(
                    alignment: .leading,
                    spacing: .padding24
                ) {
                    VStack(alignment: .leading, spacing: .padding16) {
                        claimDetailsView
                        showAllAnswersView
                    }
                    audioRecordingView
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
        .detent(
            presented: $showAllAnswers,
            presentationStyle: .detent(style: [.large])
        ) {
            SubmitClaimSummaryAnswersView(answers: viewModel.summaryModel.answers)
        }
    }

    @ViewBuilder
    var claimDetailsView: some View {
        if !claimDetails.isEmpty {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(L10n.ClaimStatus.ClaimDetails.title)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    ForEach(claimDetails, id: \.title) { item in
                        HStack(alignment: .top) {
                            hText(item.title)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            hText(item.value)
                                .multilineTextAlignment(.trailing)
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
    var showAllAnswersView: some View {
        if !viewModel.summaryModel.answers.isEmpty {
            hButton(
                .medium,
                .ghost,
                content: .init(title: L10n.claimChatShowAllAnswersButton)
            ) {
                showAllAnswers = true
            }
            .hButtonTakeFullWidth(true)
            .hButtonWithBorder
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
}

struct SubmitClaimSummaryAnswersView: View {
    let answers: [ClaimIntentStepContentSummary.ClaimIntentStepContentSummaryAnswer]

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding24) {
                    hText(L10n.ClaimStatus.ClaimDetails.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(answers) { answer in
                        VStack(alignment: .leading, spacing: .padding4) {
                            hText(answer.title)
                                .accessibilityAddTraits(.isHeader)
                            SummaryAnswerValueView(value: answer.value)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, .padding16)
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.top)
    }
}

private struct SummaryAnswerValueView: View {
    let value: ClaimIntentStepContentSummary.ClaimIntentStepContentSummaryAnswer.Value

    var body: some View {
        switch value {
        case let .text(text):
            hText(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        case let .audio(url, _):
            hSection {
                TrackPlayerView(audioPlayer: AudioPlayer(url: url))
            }
            .hWithoutHorizontalPadding([.section])
        case let .files(files):
            SummaryAnswerFilesView(files: files)
        }
    }
}

private struct SummaryAnswerFilesView: View {
    @StateObject private var vm: FileGridViewModel

    init(files: [ClaimIntentStepContentSummary.ClaimIntentStepContentSummaryFileUpload]) {
        _vm = StateObject(
            wrappedValue: FileGridViewModel(
                files: files.map {
                    .init(
                        id: $0.url.absoluteString,
                        size: 0,
                        mimeType: $0.contentType,
                        name: $0.fileName,
                        source: .url(url: $0.url, mimeType: $0.contentType)
                    )
                },
                options: []
            )
        )
    }

    var body: some View {
        FilesGridView(vm: vm)
            .hFileGridAlignment(alignment: .leading)
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
            ) { viewModel.submitResponse() }
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
                        ],
                        freeTexts: [],
                        keyDetails: [
                            .init(title: "Type of claim", value: "Theft"),
                            .init(title: "Date", value: "2025-11-25"),
                            .init(title: "Location", value: "Stockholm"),
                        ],
                        answers: [
                            .init(title: "Was the bike locked?", value: .text("No")),
                            .init(
                                title: "Describe what happened",
                                value: .audio(
                                    url: URL(string: "https://hedvig.com")!,
                                    transcript: "I parked my bike and when I came back it was gone."
                                )
                            ),
                            .init(
                                title: "Any receipts?",
                                value: .files([
                                    .init(
                                        url: URL(string: "https://hedvig.com/receipt.pdf")!,
                                        contentType: .PDF,
                                        fileName: "receipt.pdf"
                                    )
                                ])
                            ),
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
