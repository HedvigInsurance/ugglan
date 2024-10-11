import Combine
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

public struct ScrollableSegmentedView<Content: View>: View {
    @ObservedObject var vm: ScrollableSegmentedViewModel
    @ViewBuilder var contentFor: (_ id: String) -> Content
    public init(
        vm: ScrollableSegmentedViewModel,
        contentFor: @escaping (_ id: String) -> Content
    ) {
        self.vm = vm
        self.contentFor = contentFor
    }
    public var body: some View {
        VStack(spacing: .padding16) {
            headerControl
            scrollableContent
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        vm.viewWidth = geo.size.width
                    }
                    .onChange(of: geo.size.width) { width in
                        vm.viewWidth = width
                    }
            }
        }
    }

    @ViewBuilder
    var headerControl: some View {
        if vm.pageModels.count > 1 {
            hSection {
                ZStack(alignment: .leading) {
                    selectedPageHeaderBackground
                    HStack(spacing: .padding4) {
                        ForEach(vm.pageModels) { model in
                            headerElement(for: model)
                        }
                    }
                }
                .padding(.padding4)
                .background {
                    hSurfaceColor.Opaque.primary.clipShape(RoundedRectangle(cornerRadius: .cornerRadiusS))
                }
            }
        }
    }

    var selectedPageHeaderBackground: some View {
        RoundedRectangle(cornerRadius: .cornerRadiusS)
            .fill(hButtonColor.SecondaryAlt.resting)
            .frame(width: vm.selectedIndicatorWidth, height: vm.selectedIndicatorHeight)
            .offset(x: vm.selectedIndicatorOffset)
    }

    func headerElement(for model: PageModel) -> some View {
        Group {
            hText(model.title, style: .label)
                .padding(.vertical, 3)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .onTapGesture {
            vm.setSelectedTab(with: model.id)
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        let frame = geo.frame(in: .global)
                        vm.updateTitleStartPositions(for: model.id, position: frame)
                    }
                    .onChange(of: geo.frame(in: .global)) { frame in
                        vm.updateTitleStartPositions(for: model.id, position: frame)
                    }
            }
        }
    }

    var scrollableContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: vm.pageSpacing) {
                ForEach(vm.pageModels) { model in
                    ScrollView {
                        VStack {
                            contentFor(model.id)
                                .frame(width: vm.viewWidth)
                                .background {
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                vm.updateContentHeight(for: model.id, height: geo.size.height)
                                            }
                                            .onChange(of: geo.size.height) { height in
                                                vm.updateContentHeight(for: model.id, height: height)
                                            }
                                    }
                                }
                            Spacer()
                        }
                    }
                    .setDisabledScroll()
                }
            }
        }
        .findScrollView { scrollView in
            vm.horizontalScrollView = scrollView
        }
        .frame(height: vm.currentHeight == 0 ? nil : vm.currentHeight)
    }
}

public class ScrollableSegmentedViewModel: NSObject, ObservableObject {
    let pageModels: [PageModel]
    var heights: [String: CGFloat] = [:]
    var titlesPositions: [String: CGRect] = [:]
    let pageSpacing: CGFloat = 0
    @Published var viewWidth: CGFloat = 0
    private var horizontalScrollCancellable: AnyCancellable?
    @Published var selectedIndicatorWidth: CGFloat = 0
    @Published var selectedIndicatorHeight: CGFloat = 0
    @Published var selectedIndicatorOffset: CGFloat = 0
    @Published var currentHeight: CGFloat = 0
    @Published var currentId: String

    weak var horizontalScrollView: UIScrollView? {
        didSet {
            horizontalScrollView?.delegate = self
            setSelectedTab(with: currentId, withAnimation: false)
            horizontalScrollCancellable = horizontalScrollView?.publisher(for: \.contentOffset).removeDuplicates()
                .sink(receiveValue: { [weak self] value in
                    guard let self = self else { return }
                    if pageModels.count < 2 {
                        return
                    }
                    let allOffsets = self.getPagesOffset()
                    let titlePositions = self.titlesPositions.values.sorted(by: { $0.origin.x < $1.origin.x })
                    let sortedTitlePositions =
                        titlePositions.compactMap { rect in
                            return CGRect(
                                x: rect.origin.x - titlePositions[0].origin.x,
                                y: rect.origin.y,
                                width: rect.width,
                                height: rect.height
                            )
                        }
                        .compactMap({ $0.origin.x })
                    let offset = value.x
                    let lowerBoundry = allOffsets.lastIndex(where: { $0 <= offset })
                    let upperBoundry = allOffsets.firstIndex(where: { $0 >= offset })
                    if let lowerBoundry, let upperBoundry {
                        if lowerBoundry == upperBoundry {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.selectedIndicatorOffset = sortedTitlePositions[lowerBoundry]
                            }
                        } else {
                            let scrollViewMinOffset = allOffsets[lowerBoundry]
                            let scrollViewMaxOffset = allOffsets[upperBoundry]
                            let percentageDone =
                                (offset - scrollViewMinOffset) / (scrollViewMaxOffset - scrollViewMinOffset)
                            let minXForOffset = sortedTitlePositions[lowerBoundry]
                            let maxXForOffset = sortedTitlePositions[upperBoundry]
                            let newOffset = minXForOffset + (maxXForOffset - minXForOffset) * percentageDone
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.selectedIndicatorOffset = newOffset
                            }
                        }
                    }
                })
        }
    }

    func updateContentHeight(for id: String, height: CGFloat) {
        heights[id] = CGFloat(Int(height))
        if id == currentId, let height = heights[id] {
            withAnimation {
                currentHeight = height
            }
        }
    }

    func updateTitleStartPositions(for id: String, position: CGRect) {
        titlesPositions[id] = CGRect(
            x: position.origin.x,
            y: position.origin.y,
            width: CGFloat(Int(position.width)),
            height: CGFloat(Int(position.height))
        )
        selectedIndicatorWidth = CGFloat(Int(position.width))
        selectedIndicatorHeight = CGFloat(Int(position.height))
    }

    func scrollToNearestWith(offset: CGFloat) {
        let allOffsets = getPagesOffset()
        let nearestTabOffset = getNearestTabOffset(for: offset)
        if let index = allOffsets.firstIndex(of: nearestTabOffset) {
            setSelectedTab(with: pageModels[index].id)
        }
        scrollTo(offset: nearestTabOffset)
    }

    func getNearestTabOffset(for offset: CGFloat) -> CGFloat {
        let allOffsets = getPagesOffset()
        let offsetToScrollTo = allOffsets.min(by: { abs($0 - offset) < abs($1 - offset) }) ?? 0
        return offsetToScrollTo
    }

    func setSelectedTab(with id: String, withAnimation animation: Bool = true) {
        if let index = pageModels.firstIndex(where: { $0.id == id }) {
            currentId = id
            scrollTo(offset: CGFloat(index) * viewWidth + pageSpacing * CGFloat(index), withAnimation: animation)
            withAnimation {
                currentHeight = (heights[id] ?? 0)
            }
        }
    }

    private func getPagesOffset() -> [CGFloat] {
        return pageModels.enumerated().compactMap({ CGFloat($0.offset) * viewWidth + pageSpacing * CGFloat($0.offset) })
    }

    func scrollTo(offset: CGFloat, withAnimation: Bool = true) {
        horizontalScrollView?
            .scrollRectToVisible(.init(x: offset, y: 1, width: viewWidth, height: 1), animated: withAnimation)
    }
    public init(pageModels: [PageModel], currentId: String? = nil) {
        self.currentId = currentId ?? pageModels.first?.id ?? ""
        self.pageModels = pageModels
    }
}

extension ScrollableSegmentedViewModel: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestWith(offset: scrollView.contentOffset.x)
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
            let scrollTo = getNearestTabOffset(for: targetContentOffset.pointee.x)
            DispatchQueue.main.async { [weak scrollView] in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: UIView.AnimationOptions.curveEaseOut,
                    animations: {
                        scrollView?.contentOffset.x = scrollTo
                    },
                    completion: { [weak self] _ in
                        if let index = self?.getPagesOffset().firstIndex(where: { $0 == scrollTo }),
                            let idToScrollTo = self?.pageModels[index].id
                        {
                            self?.setSelectedTab(with: idToScrollTo)
                        }
                    }
                )
            }
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentHeight = heights.values.max(by: { $1 > $0 }) ?? 0
    }
}

public struct PageModel: Identifiable {
    public let id: String
    let title: String

    public init(
        id: String,
        title: String
    ) {
        self.id = id
        self.title = title
    }
}

extension View {
    @MainActor
    func setDisabledScroll() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollDisabled(true)
        } else {
            return self.introspect(.scrollView, on: .iOS(.v13...)) { view in
                view.isScrollEnabled = false
                view.isUserInteractionEnabled = false
            }
        }
    }
}
