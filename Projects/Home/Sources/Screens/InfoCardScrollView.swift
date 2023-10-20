import SwiftUI

public struct InfoCardScrollView<Content: View, cardItem: Identifiable>: View {
    private let content: (cardItem) -> Content
    private let spacing: CGFloat
    let items: [cardItem]

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
        items: [cardItem],
        zoomFactor: CGFloat = 0.9,
        @ViewBuilder content: @escaping (cardItem) -> Content
    ) {
        self.spacing = spacing
        self.cardWidth = screenWidth * zoomFactor
        self.numberOfItems = CGFloat(items.count)
        self.cardWithSpacing = cardWidth + spacing
        self.xOffsetToShift = cardWithSpacing * numberOfItems / 2 - cardWithSpacing / 2
        self._calcOffset = .init(wrappedValue: self.xOffsetToShift)
        self.items = items
        self.content = content
    }

    var dragOverTap: some Gesture {
        TapGesture()
            .exclusively(
                before:
                    DragGesture(minimumDistance: 0)
                    .onChanged { currentState in
                        self.calculateOffset(Float(currentState.translation.width))
                    }
                    .onEnded { value in
                        self.handleDragEnd(value.translation.width)
                    }
            )
    }

    public var body: some View {
        VStack {
            HStack(spacing: spacing) {
                ForEach(items) { item in
                    PrioritizedCard(
                        item,
                        width: cardWidth,
                        content: content
                    )
                }
            }
            .frame(width: cardWidth)
            .offset(x: calcOffset, y: 0)
            .animation(
                .easeInOut(duration: 0.15)
            )
            .gesture(dragOverTap, including: .gesture)
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
        if translationWidth < -50 && CGFloat(activeCard) < numberOfItems - 1 {
            activeCard += 1
        }
        if translationWidth > 50 && activeCard != 0 {
            activeCard -= 1
        }
        self.calculateOffset(0)
    }
}

struct PrioritizedCard<Content: View, cardItem: Identifiable>: View {
    private let content: Content
    private let width: CGFloat

    init(
        _ item: cardItem,
        width: CGFloat,
        @ViewBuilder content: (_ item: cardItem) -> Content
    ) {
        self.width = width
        self.content = content(item)
    }

    var body: some View {
        self.content
            .frame(width: width)
    }
}

struct InfoCardView: Identifiable {
    let id = UUID()
    let type: InfoCardType
}

enum InfoCardType {
    case importantMessage
    case payment
    case renewal
    case deletedView
}
