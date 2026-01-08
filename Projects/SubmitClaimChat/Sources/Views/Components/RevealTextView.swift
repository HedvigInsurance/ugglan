import SwiftUI
import hCore
import hCoreUI

struct RevealTextView: View {
    let text: String
    @State private var visibleCharacters: [Int: Double] = [:]
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
            if #available(iOS 18.0, *) {
                hText(text, style: .heading1)
                    .textRenderer(AnimatedTextRenderer(visibleCharacters: visibleCharacters))
                    .onAppear {
                        animateText()
                    }
            } else {
                hText(text)
            }
        }
        .animation(.easeIn(duration: 0.1), value: showDot)
        .animation(.easeIn(duration: 0.1), value: visibleCharacters)
    }

    private func animateText() {
        Task {
            try? await Task.sleep(seconds: delay)
            showDot = false

            var characterIndex = 0
            var elapsedTime: Float = 0
            let slowModeThreshold: Float = 1.0

            for textIndex in 0..<text.count {
                let character = getCharacter(at: textIndex)
                let isSlowMode = elapsedTime < slowModeThreshold

                // Render character (skip newlines)
                if character != "\n" {
                    // based on Linguistics and TextRendered, it treats tt as one glyph
                    // in this case we should skip fade to avoid odd fade next to the punctuationOrNewline
                    if textIndex > 0 && character == "t" && getCharacter(at: textIndex - 1) == "t" {
                    } else {
                        startCharacterFadeIn(at: characterIndex)
                        characterIndex += 1
                    }
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

    private func startCharacterFadeIn(at index: Int) {
        let opacitySteps = 20
        let stepDuration: Float = 0.03

        Task {
            for step in 0...opacitySteps {
                try? await Task.sleep(seconds: stepDuration)
                visibleCharacters[index] = Double(step) / Double(opacitySteps)
            }
        }
    }
}

@available(iOS 18.0, *)
struct AnimatedTextRenderer: TextRenderer {
    let visibleCharacters: [Int: Double]

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var characterIndex = 0

        for line in layout {
            for run in line {
                for glyph in run {
                    var glyphContext = context

                    let opacity: Double
                    if let item = visibleCharacters[characterIndex] {
                        opacity = item
                    } else {
                        opacity = 0
                    }
                    glyphContext.opacity = opacity
                    glyphContext.draw(glyph)
                    characterIndex += 1
                }
            }
        }
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
