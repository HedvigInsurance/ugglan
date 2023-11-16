import Combine
import SwiftUI

public struct InfoCardScrollView<Content: View, cardItem: Identifiable>: View {
    private let content: (cardItem) -> Content
    private let items: [cardItem]
    @ObservedObject private var vm: InfoCardScrollViewModel
    public init(
        spacing: CGFloat,
        items: [cardItem],
        zoomFactor: CGFloat = 0.9,
        previousHeight: CGFloat,
        @ViewBuilder content: @escaping (cardItem) -> Content
    ) {
        vm = InfoCardScrollViewModel(
            spacing: spacing,
            zoomFactor: zoomFactor,
            previousHeight: previousHeight,
            itemsCount: items.count
        )
        self.items = items
        self.content = content
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: vm.spacing) {
                ForEach(items) { item in
                    PrioritizedCard(
                        item,
                        width: vm.cardWidth,
                        updateHeight: { height in
                            if height > vm.scrollViewHeight {
                                vm.scrollViewHeight = height
                            }
                        },
                        content: content
                    )
                }
            }
        }
        .transition(.offset(.zero))
        .animation(.easeInOut(duration: 0.1))
        .frame(width: vm.cardWidth, height: vm.scrollViewHeight)
        .introspectScrollView { scrollView in
            scrollView.delegate = vm
            scrollView.clipsToBounds = false
        }
    }
}

struct PrioritizedCard<Content: View, cardItem: Identifiable>: View {
    private let content: Content
    private let width: CGFloat
    private let updateHeight: (_ width: CGFloat) -> Void
    init(
        _ item: cardItem,
        width: CGFloat,
        updateHeight: @escaping (_ width: CGFloat) -> Void,
        @ViewBuilder content: (_ item: cardItem) -> Content
    ) {
        self.width = width
        self.updateHeight = updateHeight
        self.content = content(item)
    }

    var body: some View {
        self.content
            .frame(width: width)
            .background(
                GeometryReader { geo in
                    Color.clear.onReceive(Just(geo.size.height)) { height in
                        updateHeight(height)
                    }
                }
            )
    }
}

class InfoCardScrollViewModel: NSObject, ObservableObject, UIScrollViewDelegate {
    @Published var activeCard = 0
    @Published var calcOffset: CGFloat = 0
    @Published var scrollViewHeight: CGFloat = 0
    let spacing: CGFloat
    let cardWidth: CGFloat
    let numberOfItems: CGFloat
    let cardWithSpacing: CGFloat

    init(
        spacing: CGFloat,
        zoomFactor: CGFloat,
        previousHeight: CGFloat,
        itemsCount: Int
    ) {
        self.spacing = spacing
        self.cardWidth = UIScreen.main.bounds.width * zoomFactor
        self.numberOfItems = CGFloat(itemsCount)
        self.cardWithSpacing = cardWidth + spacing
        self.scrollViewHeight = itemsCount == 0 ? 0 : previousHeight
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateOffset(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            calculateOffset(scrollView: scrollView)
        }
    }

    func calculateOffset(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        var indexToScroll = Int(offset / cardWidth)
        let valueOver = (offset - CGFloat(indexToScroll) * cardWithSpacing) / cardWithSpacing
        if valueOver > 0.5 {
            indexToScroll += 1
        }
        scrollView.setContentOffset(.init(x: CGFloat(indexToScroll) * cardWithSpacing, y: 0), animated: true)
    }
}
