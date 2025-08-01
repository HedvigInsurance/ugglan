import SwiftUI

public struct hCarousel<Content: View, hCarouselItem: Identifiable>: View {
    private let content: (hCarouselItem) -> Content
    private let spacing: CGFloat
    let items: [hCarouselItem]

    private let tapAction: (hCarouselItem) -> Void

    @State private var screenDrag: Float = 0.0
    @State private var activeCard = 0
    @State private var calcOffset: CGFloat

    private let cardWidth: CGFloat
    private let numberOfItems: CGFloat
    private let screenWidth = UIScreen.main.bounds.width
    private let cardWithSpacing: CGFloat
    private let xOffsetToShift: CGFloat

    public init(
        spacing: CGFloat,
        items: [hCarouselItem],
        zoomFactor: CGFloat = 0.9,
        tapAction: @escaping (hCarouselItem) -> Void,
        @ViewBuilder content: @escaping (hCarouselItem) -> Content
    ) {
        self.spacing = spacing
        cardWidth = screenWidth * zoomFactor
        numberOfItems = CGFloat(items.count)
        cardWithSpacing = cardWidth + spacing
        xOffsetToShift = cardWithSpacing * numberOfItems / 2 - cardWithSpacing / 2
        _calcOffset = .init(wrappedValue: xOffsetToShift)
        self.items = items
        self.content = content
        self.tapAction = tapAction
    }

    var dragOverTap: some Gesture {
        TapGesture()
            .onEnded { _ in
                if activeCard >= 0, activeCard < items.count {
                    tapAction(items[activeCard])
                }
            }
            .exclusively(
                before:
                    DragGesture(minimumDistance: 0)
                    .onChanged { currentState in
                        calculateOffset(Float(currentState.translation.width))
                    }
                    .onEnded { value in
                        handleDragEnd(value.translation.width)
                    }
            )
    }

    public var body: some View {
        VStack {
            HStack(spacing: spacing) {
                ForEach(items) { item in
                    hCarouselCard(
                        item,
                        width: cardWidth,
                        content: content
                    )
                }
            }
            .frame(width: cardWidth)
            .offset(x: calcOffset, y: 0)
            .animation(
                .easeInOut(duration: 0.15),
                value: UUID()
            )
            .gesture(dragOverTap, including: .gesture)

            hPagerDots(currentIndex: activeCard, totalCount: items.count)
        }
    }

    func calculateOffset(_ screenDrag: Float) {
        let activeOffset = xOffsetToShift - (cardWithSpacing * CGFloat(activeCard))
        let nextOffset = xOffsetToShift - (cardWithSpacing * CGFloat(activeCard + 1))
        calcOffset = activeOffset
        if activeOffset != nextOffset {
            calcOffset = activeOffset + CGFloat(screenDrag)
        }
    }

    func handleDragEnd(_ translationWidth: CGFloat) {
        if translationWidth < -50, CGFloat(activeCard) < numberOfItems - 1 {
            activeCard += 1
        }
        if translationWidth > 50, activeCard != 0 {
            activeCard -= 1
        }
        calculateOffset(0)
    }
}

struct hCarouselCard<Content: View, hCarouselItem: Identifiable>: View {
    private let content: Content
    private let width: CGFloat

    init(
        _ item: hCarouselItem,
        width: CGFloat,
        @ViewBuilder content: (_ item: hCarouselItem) -> Content
    ) {
        self.width = width
        self.content = content(item)
    }

    var body: some View {
        content
            .frame(width: width)
    }
}
