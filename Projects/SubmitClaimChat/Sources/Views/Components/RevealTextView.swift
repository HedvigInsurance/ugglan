import SwiftUI
import hCore
import hCoreUI

struct RevealTextView: View {
    @State private var visibleCharacters: [Int: Double] = [:]
    @State private var showDot = true
    @State private var animationCompleted = false
    let text: String
    var animate: Bool { _animate && !disableSubmitChatClaimAnimations }
    private let _animate: Bool
    let initialDelay: TimeInterval
    private var onTextAnimationDone: (() -> Void)
    init(
        text: String,
        initialDelay: TimeInterval,
        animate: Bool = true,
        onTextAnimationDone: @escaping (() -> Void)
    ) {
        self.text = text
        self.initialDelay = initialDelay
        self._animate = animate
        self.onTextAnimationDone = onTextAnimationDone
    }
    var body: some View {
        ZStack(alignment: .topLeading) {
            if animate, #available(iOS 18.0, *) {
                hText(text, style: .heading1)
                    .textRenderer(AnimatedTextRenderer(visibleCharacters: visibleCharacters))
                    .onAppear {
                        if !animationCompleted {
                            animateText()
                        }
                    }
            } else {
                hText(text)
                    .onAppear {
                        onTextAnimationDone()
                    }
            }
        }
        .animation(.easeIn(duration: 0.1), value: showDot)
        .animation(.easeIn(duration: 0.1), value: visibleCharacters)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        .accessibilityAddTraits(.isStaticText)
    }

    private func animateText() {
        Task {
            await delay(initialDelay)
            showDot = false

            var characterIndex = 0
            var elapsedTime = 0.0
            let slowModeThreshold = 1.0

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
                await delay(TimeInterval(sleepDuration))

                if isSlowMode {
                    elapsedTime += sleepDuration
                }
            }
            onTextAnimationDone()
            animationCompleted = true
        }
    }

    private func calculateDelay(for character: String, slowMode: Bool) -> TimeInterval {
        let isPunctuationOrNewline = [".", "?", "!", "\n"].contains(character)
        if slowMode {
            let punctuationDelay = isPunctuationOrNewline ? 0.2 : 0
            let baseDelay = 0.02
            return punctuationDelay + baseDelay
        } else {
            let punctuationDelay = isPunctuationOrNewline ? 0.05 : 0
            let baseDelay = 0.008
            return punctuationDelay + baseDelay
        }
    }

    private func getCharacter(at index: Int) -> String {
        let start = text.index(text.startIndex, offsetBy: index)
        return String(text[start...start])
    }

    private func startCharacterFadeIn(at index: Int) {
        let opacitySteps = 20
        let stepDuration = 0.03

        Task {
            for step in 0...opacitySteps {
                await delay(stepDuration)
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
        initialDelay: 0,
        onTextAnimationDone: {}
    )
}
