import SwiftUI
import hCore
import hCoreUI

struct RevealTextView: View {
    let text: String
    @State private var visibleCharacters: Int = 0
    @State private var showDot = false
    let delay: Float
    init(text: String, delay: Float, showDot: Bool = true) {
        self.text = text
        self.delay = delay
        self._showDot = State(initialValue: showDot)
    }
    var body: some View {
        ZStack(alignment: .leading) {
            if showDot {
                AnimatedDotView()
            }
            if #available(iOS 18.0, *) {
                hText(text)
                    .textRenderer(AnimatedTextRenderer(visibleCharacters: visibleCharacters))
                    .onAppear {
                        animateText()
                    }
            } else {
                Text(String(text.prefix(visibleCharacters)))
                    .onAppear {
                        animateText()
                    }
            }
        }
        .animation(.easeIn(duration: 0.1), value: showDot)
        .animation(.easeIn(duration: 0.1), value: visibleCharacters)
    }

    private func animateText() {
        visibleCharacters = 0
        Task {
            try? await Task.sleep(seconds: delay)
            for index in 0...text.count {
                try? await Task.sleep(seconds: 0.03)
                showDot = false
                visibleCharacters = index
            }
        }
    }
}

@available(iOS 18.0, *)
struct AnimatedTextRenderer: TextRenderer {
    let visibleCharacters: Int

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var characterIndex = 0

        for line in layout {
            for run in line {
                for glyph in run {
                    var glyphContext = context

                    // Calculate opacity based on proximity to visibleCharacters
                    let opacity: Double
                    if characterIndex < visibleCharacters - 1 {
                        opacity = 1.0
                    } else if characterIndex == visibleCharacters - 1 {
                        // Animate the current character
                        opacity = 1.0
                    } else if characterIndex == visibleCharacters && characterIndex != 0 {
                        // Next character starting to fade in
                        opacity = 0.3
                    } else {
                        opacity = 0.0
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
        text: "TEXT WE WANT TO SEE ANIMATED ANIMATED ANIMATE ANIMTED",
        delay: 0
    )
}
