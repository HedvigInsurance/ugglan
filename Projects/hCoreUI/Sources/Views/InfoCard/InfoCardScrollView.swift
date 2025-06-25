import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct InfoCardScrollView<Content: View, cardItem: Identifiable & Equatable>: View {
    private let content: (cardItem) -> Content
    @Binding var items: [cardItem]
    @ObservedObject private var vm: InfoCardScrollViewModel

    public init(
        items: Binding<[cardItem]>,
        vm: InfoCardScrollViewModel,
        @ViewBuilder content: @escaping (cardItem) -> Content
    ) {
        self.content = content
        self._items = items
        self.vm = vm
    }

    public var body: some View {
        HStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    if vm.cardWidth > 0 {
                        HStack(alignment: .bottom, spacing: vm.spacing) {
                            ForEach(items) { item in
                                PrioritizedCard(
                                    item,
                                    width: $vm.cardWidth,
                                    content: content
                                )
                            }
                        }
                    }
                }
                .introspect(.scrollView, on: .iOS(.v13...)) { [weak vm] scrollView in
                    vm?.scrollView = scrollView
                    scrollView.delegate = vm
                    scrollView.clipsToBounds = false
                }
                if vm.cardWidth > 0 {
                    if items.count > 1 {
                        hPagerDotsBinded(currentIndex: $vm.activeCard, totalCount: items.count)
                    }
                }
            }
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { [weak vm] in
                        Task {
                            await vm?.updateWidth(with: proxy.size.width)
                        }
                    }
                    .onChange(of: proxy.size) { [weak vm] size in
                        Task {
                            await vm?.updateWidth(with: size.width)
                        }
                    }
            }
        }
        .onAppear {
            vm.updateItems(count: items.count)
        }
        .onChange(of: items) { value in
            vm.updateItems(count: value.count)
        }
    }
}

struct PrioritizedCard<Content: View, cardItem: Identifiable>: View {
    private let content: Content
    @Binding var width: CGFloat
    init(
        _ item: cardItem,
        width: Binding<CGFloat>,
        @ViewBuilder content: (_ item: cardItem) -> Content
    ) {
        self._width = width
        self.content = content(item)
    }

    var body: some View {
        self.content
            .frame(width: width)
    }
}

@MainActor
public class InfoCardScrollViewModel: NSObject, ObservableObject {
    @Published var activeCard = 0
    @Published var calcOffset: CGFloat = 0
    @Published var itemsCount: Int = 0
    @Published var spacing: CGFloat = 0
    @Published var cardWidth: CGFloat = 0
    @Published var cardWithSpacing: CGFloat = 0
    var scrollView: UIScrollView?
    public init(
        spacing: CGFloat
    ) {
        self.spacing = spacing
    }

    public func updateWidth(with cardWidth: CGFloat) async {
        self.cardWidth = cardWidth
        self.cardWithSpacing = cardWidth + spacing
        if let scrollView {
            await calculateOffset(scrollView: scrollView)
        }

    }

    public func updateItems(count: Int) {
        withAnimation {
            itemsCount = count
            if count == activeCard {
                activeCard -= 1
            }
        }
    }
}

extension InfoCardScrollViewModel: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            Task {
                await calculateOffset(scrollView: scrollView)
            }
        }
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if velocity.x != 0 {
            if #available(iOS 17.4, *) {
                scrollView.stopScrollingAndZooming()
            }
            let indexToScroll: Int = {
                if velocity.x > 1 && activeCard != itemsCount - 1 {
                    return activeCard + 1
                } else if velocity.x < -1 && activeCard > 0 {
                    return activeCard - 1
                } else {
                    let offset = targetContentOffset.pointee.x
                    var indexToScroll = Int(offset / cardWidth)
                    let valueOver = (offset - CGFloat(indexToScroll) * cardWithSpacing) / cardWithSpacing
                    if valueOver > 0.5 {
                        indexToScroll += 1
                    }
                    return indexToScroll
                }
            }()
            withAnimation {
                self.activeCard = indexToScroll
            }
            let offsetToScrollTo = CGFloat(indexToScroll) * cardWithSpacing
            DispatchQueue.main.async { [weak scrollView] in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: [UIView.AnimationOptions.curveEaseOut, UIView.AnimationOptions.allowUserInteraction],
                    animations: {
                        scrollView?.contentOffset.x = offsetToScrollTo
                    },
                    completion: { _ in
                    }
                )
            }
        }
    }

    func calculateOffset(scrollView: UIScrollView) async {
        let offset = scrollView.contentOffset.x
        var indexToScroll = Int(offset / self.cardWidth)
        let valueOver = (offset - CGFloat(indexToScroll) * self.cardWithSpacing) / self.cardWithSpacing
        if valueOver > 0.5 {
            indexToScroll += 1
        }
        withAnimation {
            self.activeCard = indexToScroll
        }
        scrollView.setContentOffset(.init(x: CGFloat(indexToScroll) * self.cardWithSpacing, y: 0), animated: true)
    }
}
