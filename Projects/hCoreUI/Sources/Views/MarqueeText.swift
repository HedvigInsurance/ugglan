import Combine
import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var startDelay: Double
    public var alignment: Alignment

    @State private var animate = false
    var isCompact = false

    public var body: some View {
        let stringWidth = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)

        return ZStack {
            GeometryReader { geo in
                if stringWidth > geo.size.width {  // don't use self.animate as conditional here
                    Group {
                        Text(text)
                            .lineLimit(1)
                            .font(.init(font))
                            .offset(x: animate ? -(stringWidth - geo.size.width) - 6 : 0)
                            .fixedSize(horizontal: true, vertical: false)
                            // Pin the text to exactly one line so a layout pass can never
                            // give it vertical room to drift or wrap into.
                            .frame(height: stringHeight, alignment: .leading)
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )
                            .onAppear {
                                DispatchQueue.main.async {
                                    updateAnimation(
                                        shouldAnimate: geo.size.width < stringWidth,
                                        stringWidth: stringWidth,
                                        containerWidth: geo.size.width
                                    )
                                }
                            }
                    }
                    .onChange(of: text) { _ in
                        updateAnimation(
                            shouldAnimate: geo.size.width < stringWidth,
                            stringWidth: stringWidth,
                            containerWidth: geo.size.width
                        )
                    }

                    .offset(x: leftFade)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: 2)
                                .opacity(0)
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                                startPoint: /*@START_MENU_TOKEN@*/ .leading /*@END_MENU_TOKEN@*/,
                                endPoint: /*@START_MENU_TOKEN@*/ .trailing /*@END_MENU_TOKEN@*/
                            )
                            .frame(width: leftFade)
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, Color.black]),
                                startPoint: /*@START_MENU_TOKEN@*/ .leading /*@END_MENU_TOKEN@*/,
                                endPoint: /*@START_MENU_TOKEN@*/ .trailing /*@END_MENU_TOKEN@*/
                            )
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                                startPoint: /*@START_MENU_TOKEN@*/ .leading /*@END_MENU_TOKEN@*/,
                                endPoint: /*@START_MENU_TOKEN@*/ .trailing /*@END_MENU_TOKEN@*/
                            )
                            .frame(width: rightFade)
                            Rectangle()
                                .frame(width: 2)
                                .opacity(0)
                        }
                    )
                    .frame(width: geo.size.width + leftFade)
                    .offset(x: leftFade * -1)
                } else {
                    Text(text)
                        .font(.init(font))
                        .lineLimit(1)
                        .onChange(of: text) { _ in
                            updateAnimation(
                                shouldAnimate: geo.size.width < stringWidth,
                                stringWidth: stringWidth,
                                containerWidth: geo.size.width
                            )
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: alignment
                        )
                }
            }
        }
        .frame(height: stringHeight)
        // Guard against any vertical overflow ever showing as a top/bottom drift.
        .clipped()
        .frame(maxWidth: isCompact ? stringWidth : nil)
        .onDisappear { animate = false }
    }

    /// Drives the marquee by animating only the horizontal `offset`. Using an explicit
    /// `withAnimation` (instead of an implicit `.animation(_:value:)` on the whole subtree)
    /// keeps the repeating animation from ever capturing a vertical layout change and
    /// scrolling the text top-to-bottom.
    private func updateAnimation(shouldAnimate: Bool, stringWidth: CGFloat, containerWidth: CGFloat) {
        guard shouldAnimate else {
            animate = false
            return
        }
        animate = false
        withAnimation(
            .easeInOut(duration: 1.5 + Double(stringWidth - containerWidth) / 40)
                .delay(startDelay)
                .repeatForever(autoreverses: true)
        ) {
            animate = true
        }
    }

    public init(
        text: String,
        font: UIFont,
        leftFade: CGFloat,
        rightFade: CGFloat,
        startDelay: Double,
        alignment: Alignment? = nil
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment ?? .topLeading
    }
}

extension MarqueeText {
    public func makeCompact(_ compact: Bool = true) -> Self {
        var view = self
        view.isCompact = compact
        return view
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}

#Preview {
    VStack {
        MarqueeText(
            text: "1234567890 1234567890 1234567890",
            font: .systemFont(ofSize: 20),
            leftFade: 3,
            rightFade: 3,
            startDelay: 0
        )
    }
    .frame(width: 100)
}
