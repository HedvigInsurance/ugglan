import SwiftUI
import hCore
import hCoreUI

struct RevealTextView: View {
    let text: String
    @State private var attributedText = AttributedString()
    @State private var showDot = true
    let delay: Float

    private var onTextAnimationDone: (() -> Void)
    init(
        text: String,
        delay: Float,
        onTextAnimationDone: @escaping (() -> Void)
    ) {
        self.text = text
        self.delay = delay
        self.onTextAnimationDone = onTextAnimationDone
    }
    var body: some View {
        ZStack(alignment: .topLeading) {
            if showDot {
                AnimatedDotView()
            }
            Text(attributedText)
                .onAppear {
                    animateText()
                }
        }
        .animation(.easeIn(duration: 0.1), value: showDot)
    }

    private func animateText() {
        Task(priority: .userInitiated) {
            try? await Task.sleep(seconds: delay)
            showDot = false
            var currentText = AttributedString(text)
            currentText.font = Fonts.fontFor(style: .heading1)
            var elapsedTime: Float = 0
            let slowModeThreshold: Float = 1.0

            // Initially set all characters to transparent
            for run in currentText.runs {
                currentText[run.range].foregroundColor = textColor.withAlphaComponent(0)
            }
            attributedText = currentText

            for textIndex in 0..<text.count {
                let character = getCharacter(at: textIndex)
                let isSlowMode = elapsedTime < slowModeThreshold

                // Render character
                if !character.contains(where: { $0.isNewline }) {
                    await startCharacterFadeIn(at: textIndex)
                }

                // Calculate and apply delay
                let sleepDuration = calculateDelay(for: character, slowMode: isSlowMode)
                try? await Task.sleep(seconds: sleepDuration)

                if isSlowMode {
                    elapsedTime += sleepDuration
                }
            }
            onTextAnimationDone()
        }
    }

    private func calculateDelay(for character: String, slowMode: Bool) -> Float {
        let isPunctuationOrNewline = [".", "?", "!", "\n"].contains(character)

        if slowMode {
            let punctuationDelay: Float = isPunctuationOrNewline ? 0.2 : 0
            let baseDelay: Float = 0.02
            return punctuationDelay + baseDelay
        } else {
            let punctuationDelay: Float = isPunctuationOrNewline ? 0.05 : 0
            let baseDelay: Float = 0.008
            return punctuationDelay + baseDelay
        }
    }

    private func getCharacter(at index: Int) -> String {
        let start = text.index(text.startIndex, offsetBy: index)
        return String(text[start...start])
    }

    private let textColor = UIColor.init(
        light: hTextColor.Opaque.primary
            .colorFor(
                .light,
                .base
            )
            .color.uiColor(),
        dark: hTextColor.Opaque.primary
            .colorFor(
                .dark,
                .base
            )
            .color.uiColor()
    )
    private func startCharacterFadeIn(at index: Int) async {
        let opacitySteps = 10
        let stepDuration: Float = 0.03
        let characterIndex = text.index(text.startIndex, offsetBy: index)
        let range = characterIndex...characterIndex
        Task.detached(
            priority: .low,
            operation: {
                for step in 0...opacitySteps {
                    try? await Task.sleep(seconds: stepDuration)
                    let opacity = Double(step) / Double(opacitySteps)
                    await MainActor.run {
                        if let attributedRange = Range(range, in: attributedText) {
                            attributedText[attributedRange].foregroundColor = textColor.withAlphaComponent(opacity)
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    RevealTextView(
        text: """
            Hedvig förenklar sin bolagsstruktur och samlar hela koncernens verksamhet i bolaget Hedvig Försäkring AB.

            Hedvigs Hemförsäkring Max med tillägget Reseskydd Plus belönas med ett av de högsta poängen när Konsumenternas Försäkringsbyrå jämför skyddet hos olika försäkringsbolag. Se hela jämförelsen på konsumenternas.se.
            """,
        delay: 0,
        onTextAnimationDone: {}
    )
}
