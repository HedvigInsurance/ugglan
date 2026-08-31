import SwiftUI
import hCore

/// Auto-scrolling ("marquee") single-line text.
///
/// When the text is wider than the available width it ping-pongs horizontally — scrolling to
/// the end, pausing, then back to the start — and repeats forever. When the text fits, it
/// stays put. The leading/trailing edges are softened with a fade so text slides in and out
/// gently rather than being hard-clipped.
public struct MarqueeText: View {
    public var text: String
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    /// How long to hold at each end before scrolling back.
    public var pauseDuration: TimeInterval

    /// How long a single edge-to-edge scroll takes. Longer = slower.
    private let scrollDuration: TimeInterval = 5

    public init(
        text: String,
        leftFade: CGFloat,
        rightFade: CGFloat,
        pauseDuration: TimeInterval
    ) {
        self.text = text
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.pauseDuration = pauseDuration
    }

    public var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    Rectangle().frame(width: 0)
                        .id("before")
                    hText(text, style: .label)
                        .lineLimit(1)
                    Rectangle().frame(width: 0)
                        .id("after")
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .mask(fadeMask)
            .scrollDisabled(true)
            .task {
                // Ping-pong forever: scroll to the end, hold, scroll back to the start, hold,
                // repeat. When the text fits, scrollTo is a no-op so it just idles.
                while !Task.isCancelled {
                    await scroll(scrollView, to: "after", anchor: .trailing)
                    await delay(pauseDuration)
                    await scroll(scrollView, to: "before", anchor: .leading)
                    await delay(pauseDuration)
                }
            }
        }
    }

    /// Animates a scroll to the given anchor id and waits for the animation to finish.
    @MainActor
    private func scroll(_ proxy: ScrollViewProxy, to id: String, anchor: UnitPoint) async {
        withAnimation(.easeInOut(duration: scrollDuration)) {
            proxy.scrollTo(id, anchor: anchor)
        }
        await delay(scrollDuration)
    }

    /// Soft fade at the leading/trailing edges so text slides in and out gently.
    private var fadeMask: some View {
        HStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: leftFade)
            Color.black
            LinearGradient(
                gradient: Gradient(colors: [.black, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: rightFade)
        }
    }
}

#Preview {
    VStack {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 60, height: 30)
            MarqueeText(
                text: "Placing long text that just to see how it behaves",
                leftFade: 3,
                rightFade: 3,
                pauseDuration: 2
            )
            hButton(.medium, .primary, content: .init(title: "title")) {}
        }

        HStack {
            Rectangle()
                .frame(width: 60, height: 30)
            MarqueeText(
                text: "1234567890",
                leftFade: 3,
                rightFade: 3,
                pauseDuration: 2
            )
            hButton(.medium, .primary, content: .init(title: "title")) {}
        }
    }
    .frame(maxWidth: .infinity)
}
