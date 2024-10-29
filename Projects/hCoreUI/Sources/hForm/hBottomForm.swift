import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UIKit

public struct hBottomForm<Content: View>: View, KeyboardReadable {
    var content: Content
    @StateObject private var vm = hBottomFormViewModel()
    @Environment(\.hFormBottomAttachedView) var bottomAttachedView

    public init(
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(Color.clear).frame(maxHeight: .infinity)
            contentView
            if vm.shouldPlaceTitleInTheMiddle {
                navigationBluredView
            }
            bottomAttachedView
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                if proxy.size.height > 0 {
                                    vm.bottomAttachedViewHeight = proxy.size.height
                                }
                            }
                            .onChange(of: proxy.size) { value in
                                if value.height > 0 {
                                    vm.bottomAttachedViewHeight = value.height
                                }
                            }
                    }
                }
                .frame(height: !vm.showBottomView ? 0 : vm.bottomAttachedViewHeight, alignment: .top)
                .clipped()
            titleView
        }
        .introspect(.viewController, on: .iOS(.v13...)) { viewController in
            vm.viewController = viewController
        }
        .dismissKeyboard()

    }

    private var navigationBluredView: some View {
        VStack {
            BackgroundBlurView()
                .frame(height: vm.navigationViewHeight)
                .offset(y: -vm.navigationViewHeight)
            Spacer()
        }
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hSection {
                HStack {
                    if vm.shouldPlaceTitleInTheMiddle {
                        Spacer()
                    }
                    VStack(alignment: vm.shouldPlaceTitleInTheMiddle ? .center : .leading, spacing: 0) {
                        hText("Title")
                            .foregroundColor(hTextColor.Opaque.primary)
                            .background {
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            if !vm.shouldPlaceTitleInTheMiddle {
                                                if proxy.size.height > 0 {
                                                    vm.titleViewHeight = proxy.size.height
                                                }
                                            }
                                        }
                                        .onChange(of: proxy.size) { value in
                                            if !vm.shouldPlaceTitleInTheMiddle {
                                                if value.height > 0 {
                                                    vm.titleViewHeight = value.height
                                                }
                                            }
                                        }
                                }
                            }

                        if !vm.shouldPlaceTitleInTheMiddle {
                            hText("Subtitle that goes into 2 rows is insanly long")
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    if !vm.shouldPlaceTitleInTheMiddle {
                                        if proxy.size.height > 0 {
                                            vm.titleContainerViewHeight = proxy.size.height
                                        }
                                    }
                                }
                                .onChange(of: proxy.size) { value in
                                    if !vm.shouldPlaceTitleInTheMiddle {
                                        if value.height > 0 {
                                            vm.titleContainerViewHeight = value.height
                                        }
                                    }
                                }
                        }
                    }
                    Spacer()
                }
            }
            .sectionContainerStyle(.transparent)
            .hTextStyle(.body2)
            .offset(y: vm.moveTitleFor)
            .scaleEffect(vm.navigationTitleScale, anchor: .top)
            Spacer()
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                content
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    if vm.showBottomView {
                                        vm.contentHeight = proxy.size.height
                                    }
                                }
                                .onChange(of: proxy.size) { value in
                                    if vm.showBottomView {
                                        vm.contentHeight = value.height
                                    }

                                }
                        }
                    }
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: !vm.showBottomView ? 0 : vm.bottomAttachedViewHeight)
            }
        }
        .frame(height: !vm.showBottomView ? vm.contentHeight : (vm.contentHeight + (vm.bottomAttachedViewHeight ?? 0)))
        .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
            if vm.scrollView != scrollView {
                if self.vm.keyboardObserver == nil {
                    self.vm.setKeyboard(publisher: keyboardPublisher)
                }
                vm.scrollView = scrollView
            }
        }
    }
}

private class hBottomFormViewModel: ObservableObject {
    @Published var contentHeight: CGFloat = 0
    @Published var bottomAttachedViewHeight: CGFloat?
    @Published var titleViewHeight: CGFloat?
    @Published var titleContainerViewHeight: CGFloat?
    @Published var navigationViewHeight: CGFloat = 0
    @Published var moveTitleFor: CGFloat = 0
    @Published var shouldPlaceTitleInTheMiddle = false
    @Published var navigationTitleScale: CGFloat = 1
    @Published var keyboardHeight: CGFloat = 0
    @Published var showBottomView = true

    func setKeyboard(publisher: AnyPublisher<CGFloat?, Never>) {
        keyboardObserver =
            publisher
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] keyboardHeight in
                if let scrollView = self?.scrollView {
                    self?.setScrollPosition(with: scrollView)
                }
            })
        keyboardObserver2 =
            publisher
            .sink(receiveValue: { [weak self] keyboardHeight in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self?.showBottomView = keyboardHeight == nil
                }

                if let scrollView = self?.scrollView {
                    self?.setScrollPosition(with: scrollView)
                }
            })
    }

    private(set) var keyboardObserver: AnyCancellable?
    private(set) var keyboardObserver2: AnyCancellable?

    //    private var observation: NSKeyValueObservation?
    private var observation: AnyCancellable?

    init() {}

    weak var scrollView: UIScrollView? {
        didSet {
            if let scrollView {
                DispatchQueue.main.async { [weak self] in
                    self?.setScrollPosition(with: scrollView)
                }
            }
            scrollView?.clipsToBounds = false
            observation = scrollView?.publisher(for: \.bounds)
                .receive(on: DispatchQueue.main)
                .debounce(for: 0.02, scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak scrollView] value in
                    print("BOUNDS CHANGED \(value)")
                    if let scrollView {
                        self.setScrollPosition(with: scrollView)
                    }
                })
            viewController?.setContentScrollView(scrollView)

        }
    }

    private func setScrollPosition(with scroll: UIScrollView) {
        guard let vc = viewController else { return }
        print("VALUE IS 2 \(scroll.bounds)")
        let offsetFromTop = scroll.convert(vc.view.frame.origin, to: vc.view).y
        let topSafeArea = vc.view.safeAreaInsets.top
        let spaceForTitle = offsetFromTop - topSafeArea
        let navigationHeight = vc.navigationController?.navigationBar.frame.height ?? 0
        let value = Checking(
            offsetFromTop: offsetFromTop,
            topSafeArea: topSafeArea,
            spaceForTitle: spaceForTitle,
            navigationHeight: navigationHeight
        )
        print("BOUNDS CHANGED \(value)")

        Task { @MainActor in
            self.navigationViewHeight = value.topSafeArea
            print("BOUNDS CHANGED VALUE IS \(value) \(self.titleViewHeight)")
            withAnimation(.easeInOut(duration: 0.1)) {
                if let titleViewHeight = self.titleViewHeight,
                    let titleContainerViewHeight = self.titleContainerViewHeight,
                    value.spaceForTitle < titleContainerViewHeight
                {
                    self.shouldPlaceTitleInTheMiddle = true
                    self.moveTitleFor = -value.navigationHeight / 2 - titleViewHeight / 2
                    self.navigationTitleScale = 1
                } else {
                    self.shouldPlaceTitleInTheMiddle = false
                    self.moveTitleFor = .zero
                    self.navigationTitleScale = 1
                }
            }
        }
    }

    weak var viewController: UIViewController? {
        didSet {
            viewController?.setContentScrollView(scrollView)
        }
    }
}

struct Checking {
    let offsetFromTop: CGFloat
    let topSafeArea: CGFloat
    let spaceForTitle: CGFloat
    let navigationHeight: CGFloat
}

struct hBottomForm_Previews: PreviewProvider {
    static var previews: some View {
        hBottomForm {
            hSection {
                hText("Content").frame(height: 200).background(Color.red)
                hText("Content").frame(height: 200)
                //                hText("Content").frame(height: 200).background(Color.red)
                //                hText("Content").frame(height: 200)
            }
        }
        .hFormAttachToBottom {
            hSection {
                hText("Test 1")
                hText("Test 2")
                hText("Test 3")
            }
            .padding(.vertical, .padding16)
        }
        //        .hFormTitle(title: .init(.small, .body1, "TITLE"))
    }
}
