import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimTextCard: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    var onFocus: () -> Void = {}
    @FocusState private var isFocused: Bool
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        Group {
            if verticalSizeClass == .regular {
                VStack(spacing: .padding16) {
                    inputPart
                    buttonParts
                }
            } else {
                HStack(spacing: .padding16) {
                    inputPart
                    // Buttons hug their content, the text field gets the rest of the row
                    buttonParts
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .padding(.padding16)
        .claimInputCardBackground()
        .onAppear {
            guard viewModel.shouldFocusTextInput else { return }
            Task {
                // Focus after the card has landed so the keyboard reliably opens with it.
                await delay(ClaimChatConstants.Timing.layoutUpdate)
                isFocused = true
            }
        }
        .onChange(of: isFocused) { isFocused in
            if isFocused { onFocus() }
        }
        .onChange(of: viewModel.state.isLoading) { isLoading in
            if isLoading { isFocused = false }
        }
        .onChange(of: viewModel.state.isEnabled) { isEnabled in
            if !isEnabled { isFocused = false }
        }
    }

    var inputPart: some View {
        VStack(alignment: .leading, spacing: .padding4) {
            hText(L10n.claimsTriagingWhatHappenedTitle, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
                .accessibilityHidden(true)
            TextField(L10n.chatInputPlaceholder, text: $viewModel.textInput, axis: .vertical)
                .font(Font(Fonts.fontFor(style: .body1)))
                .foregroundColor(
                    viewModel.state.isEnabled ? hTextColor.Opaque.primary : hTextColor.Opaque.secondary
                )
                .lineLimit(1...6)
                .focused($isFocused)
                .disabled(!viewModel.state.isEnabled)
                .accessibilityLabel(L10n.claimsTriagingWhatHappenedTitle)
                .accessibilityHint(
                    L10n.claimsTextInputMinCharactersError(viewModel.audioRecordingModel.freeTextMinLength)
                )
            if let error = viewModel.textInputError {
                hText(error, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .transition(.opacity)
            }
        }
        .animation(.defaultSpring, value: viewModel.textInputError)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var buttonParts: some View {
        HStack(spacing: .padding8) {
            if verticalSizeClass == .regular {
                Spacer()
            }
            hButton(.medium, .secondary, content: .init(title: L10n.generalCancelButton)) {
                viewModel.cancelInput()
            }
            .disabled(viewModel.state.isLoading)
            hButton(.medium, .primary, content: .init(title: L10n.chatUploadPresend)) {
                viewModel.saveText()
            }
            .disabled(viewModel.characterMismatch)
            .hButtonIsLoading(viewModel.state.isLoading)
            .accessibilityHint(
                viewModel.characterMismatch
                    ? L10n.claimsTextInputMinCharactersError(viewModel.audioRecordingModel.freeTextMinLength) : ""
            )
            .overlay {
                if viewModel.characterMismatch {
                    Button {
                        viewModel.saveText()
                    } label: {
                        Color.clear.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHidden(true)
                }
            }
        }
    }
}

#Preview("Text card") {
    let viewModel = SubmitClaimAudioStep.preview(textInput: "Lorem ipsum dolor sit amet")
    viewModel.beginText()
    return VStack {
        Spacer()
        ClaimInputCardView(viewModel: viewModel)
            .padding(.horizontal, .padding16)
    }
}

#Preview("Text card · too short") {
    let viewModel = SubmitClaimAudioStep.preview(textInput: "Lorem")
    viewModel.beginText()
    return VStack {
        Spacer()
        ClaimInputCardView(viewModel: viewModel)
            .padding(.horizontal, .padding16)
    }
}
