import SwiftUI
import hCore
import hCoreUI

/// Text input for the description step (Figma "App P2 2026", section "5 · Text / voice input", section 2):
/// label · multiline field · counter · Avbryt / Skicka, in a card that replaces the docked input area.
struct SubmitClaimTextCard: View {
    @ObservedObject var viewModel: SubmitClaimAudioStep
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: .padding16) {
            VStack(alignment: .leading, spacing: .padding4) {
                hText(SubmitClaimAudioStepCopy.textFieldLabel, style: .label)
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
                    .accessibilityLabel(SubmitClaimAudioStepCopy.textFieldLabel)
                    .accessibilityHint(
                        L10n.claimsTextInputMinCharactersError(viewModel.audioRecordingModel.freeTextMinLength)
                    )
                HStack(alignment: .top, spacing: .padding8) {
                    if let error = viewModel.textInputError {
                        hText(error, style: .label)
                            .foregroundColor(hSignalColor.Red.element)
                            .transition(.opacity)
                    }
                    Spacer(minLength: 0)
                    hText(characterCount, style: .label)
                        .foregroundColor(characterCountColor)
                        .accessibilityLabel(characterCount)
                }
                .animation(.defaultSpring, value: viewModel.textInputError)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: .padding8) {
                Spacer(minLength: 0)
                hButton(.medium, .secondary, content: .init(title: L10n.generalCancelButton)) { [weak viewModel] in
                    viewModel?.cancelInput()
                }
                .disabled(viewModel.state.isLoading)
                hButton(.medium, .primary, content: .init(title: L10n.chatUploadPresend)) { [weak viewModel] in
                    viewModel?.saveText()
                }
                .disabled(viewModel.characterMismatch)
                .hButtonIsLoading(viewModel.state.isLoading)
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
        .onChange(of: viewModel.state.isLoading) { isLoading in
            // Figma 2.3: the keyboard goes down while sending.
            if isLoading { isFocused = false }
        }
        .onChange(of: viewModel.state.isEnabled) { isEnabled in
            if !isEnabled { isFocused = false }
        }
    }

    private var characterCount: String {
        "\(viewModel.textInput.count)/\(viewModel.audioRecordingModel.freeTextMaxLength)"
    }

    @hColorBuilder
    private var characterCountColor: some hColor {
        if viewModel.textInput.count > viewModel.audioRecordingModel.freeTextMaxLength {
            hSignalColor.Red.element
        } else {
            hTextColor.Opaque.secondary
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
