import Combine
import SwiftUI

public struct InfoCardScrollView<Content: View, cardItem: Identifiable>: View {
    private let content: (cardItem) -> Content
    private let items: [cardItem]
    @ObservedObject private var vm: InfoCardScrollViewModel

    public init(
        items: [cardItem],
        vm: InfoCardScrollViewModel,
        @ViewBuilder content: @escaping (cardItem) -> Content
    ) {
        self.content = content
        self.items = items
        self.vm = vm
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
                                DispatchQueue.main.async { [weak vm] in
                                    vm?.scrollViewHeight = height
                                }
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
        if items.count > 1 {
            hPagerDotsBinded(currentIndex: $vm.activeCard, totalCount: items.count)
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

public class InfoCardScrollViewModel: NSObject, ObservableObject, UIScrollViewDelegate {
    @Published var activeCard = 0
    @Published var calcOffset: CGFloat = 0
    @Published var scrollViewHeight: CGFloat = 0
    @Published var itemsCount: CGFloat = 0
    let spacing: CGFloat
    let cardWidth: CGFloat
    let cardWithSpacing: CGFloat

    public init(
        spacing: CGFloat,
        zoomFactor: CGFloat,
        itemsCount: Int
    ) {
        self.spacing = spacing
        self.cardWidth = UIScreen.main.bounds.width * zoomFactor
        self.itemsCount = CGFloat(itemsCount)
        self.cardWithSpacing = cardWidth + spacing
        self.scrollViewHeight = 0
    }

    public func updateItems(count: Int) {
        withAnimation {
            itemsCount = CGFloat(count)
            if itemsCount == 0 {
                scrollViewHeight = 0
            }
            if count == activeCard {
                activeCard -= 1
            }
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateOffset(scrollView: scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
        withAnimation {
            activeCard = indexToScroll
        }
        scrollView.setContentOffset(.init(x: CGFloat(indexToScroll) * cardWithSpacing, y: 0), animated: true)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        var indexToScroll = Int(offset / cardWidth)
        let valueOver = (offset - CGFloat(indexToScroll) * cardWithSpacing) / cardWithSpacing
        if valueOver > 0.5 {
            indexToScroll += 1
        }
        withAnimation {
            activeCard = indexToScroll
        }
    }
}
