import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ScrollableSegmentedView<Content: View>: View {
    @ObservedObject var vm: ScrollableSegmentedViewModel
    @ViewBuilder var contentFor: (_ id: String) -> Content
    init(
        vm: ScrollableSegmentedViewModel,
        contentFor: @escaping (_ id: String) -> Content
    ) {
        self.vm = vm
        self.contentFor = contentFor
    }
    var body: some View {
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

    var headerControl: some View {
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
        .padding(.horizontal, .padding16)
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
        .frame(height: vm.currentHeight)
    }
}

class ScrollableSegmentedViewModel: NSObject, ObservableObject {
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
            horizontalScrollCancellable = horizontalScrollView?.publisher(for: \.contentOffset).removeDuplicates()
                .sink(receiveValue: { [weak self] value in guard let self = self else { return }
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
        heights[id] = height
        if id == currentId, let height = heights[id] {
            withAnimation {
                currentHeight = height
            }
        }
    }

    func updateTitleStartPositions(for id: String, position: CGRect) {
        titlesPositions[id] = position
        selectedIndicatorWidth = position.width
        selectedIndicatorHeight = position.height
    }

    func scrollToNearestWith(offset: CGFloat) {
        let allOffsets = getPagesOffset()
        let offsetToScrollTo = allOffsets.min(by: { abs($0 - offset) < abs($1 - offset) }) ?? 0
        if let index = allOffsets.firstIndex(of: offsetToScrollTo) {
            setSelectedTab(with: pageModels[index].id)
        }
        scrollTo(offset: offsetToScrollTo)
    }

    func setSelectedTab(with id: String) {
        if let index = pageModels.firstIndex(where: { $0.id == id }) {
            currentId = id
            scrollTo(offset: CGFloat(index) * viewWidth + pageSpacing * CGFloat(index))
            withAnimation {
                currentHeight = (heights[id] ?? 0)
            }
        }
    }

    private func getPagesOffset() -> [CGFloat] {
        return pageModels.enumerated().compactMap({ CGFloat($0.offset) * viewWidth + pageSpacing * CGFloat($0.offset) })
    }

    func scrollTo(offset: CGFloat) {
        horizontalScrollView?.scrollRectToVisible(.init(x: offset, y: 1, width: viewWidth, height: 1), animated: true)
    }
    init(pageModels: [PageModel]) {
        self.currentId = pageModels.first?.id ?? ""
        self.pageModels = pageModels
    }
}

extension ScrollableSegmentedViewModel: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestWith(offset: scrollView.contentOffset.x)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestWith(offset: scrollView.contentOffset.x)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentHeight = heights.values.max(by: { $1 > $0 }) ?? 0
    }
}

struct PageModel: Identifiable {
    let id: String
    let title: String
}

#Preview{
    let store: ContractStore = globalPresentableStoreContainer.get()

    let fetchContractsService = FetchContractsClientDemo()
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in fetchContractsService })

    let featureFlags = FeatureFlagsDemo()
    Dependencies.shared.add(module: Module { () -> FeatureFlags in featureFlags })

    store.send(.fetchContracts)
    return VStack {
        ScrollableSegmentedView(
            vm: .init(
                pageModels: [
                    .init(
                        id: "id1",
                        title: "title1"
                    ),
                    .init(
                        id: "id2",
                        title: "title2"
                    ),
                    .init(
                        id: "id3",
                        title: "title3"
                    ),
                ]
            )
        ) { id in
            Group {
                if id == "id1" {
                    ContractInformationView(id: "contractId")
                } else if id == "id2" {
                    ContractCoverageView(id: "contractId")
                } else {
                    ContractDocumentsView(id: "contractId")
                }

            }
        }
    }
    .padding(.horizontal, 10)
}

extension View {
    func setDisabledScroll() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollDisabled(true)
        } else {
            return self
        }
    }
}
