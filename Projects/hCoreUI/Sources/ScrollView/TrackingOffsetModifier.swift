import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct TrackingOffsetModifier: ViewModifier {
    @ObservedObject var vm: TracingOffsetViewModel

    public init(
        vm: TracingOffsetViewModel
    ) {
        self.vm = vm
    }

    public func body(content: Content) -> some View {
        content
            .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                if vm.scrollView != scrollView {
                    vm.scrollView = scrollView
                }
            }
    }
}

public class TracingOffsetViewModel: ObservableObject {
    private var scrollOffsetCancellable: AnyCancellable?
    @Published public var currentOffset: CGPoint = .zero

    @MainActor
    weak var scrollView: UIScrollView? {
        didSet {
            scrollOffsetCancellable = scrollView?.publisher(for: \.contentOffset)
                .sink(receiveValue: { [weak self] offset in
                    self?.currentOffset = offset
                })
        }
    }

    public init() {}
}

public struct SetOffsetModifier: ViewModifier {
    @ObservedObject var vm: SetOffsetViewModel

    public init(
        vm: SetOffsetViewModel
    ) {
        self.vm = vm
    }

    public func body(content: Content) -> some View {
        content
            .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                if vm.scrollView != scrollView {
                    vm.scrollView = scrollView
                }
            }
    }
}

public class SetOffsetViewModel: ObservableObject {
    @MainActor
    public func animate(with animationProperties: AnimationProperties) {
        let scrollTo: CGPoint = {
            var x: CGFloat = 0
            if let scrollView {
                if scrollView.frame.width + animationProperties.offset.x > scrollView.contentSize.width {
                    x = max(scrollView.contentSize.width - scrollView.frame.width, 0)
                } else {
                    x = animationProperties.offset.x
                }
            }
            return .init(x: x, y: 0)
        }()
        UIView.animate(
            withDuration: animationProperties.duration,
            delay: 0,
            usingSpringWithDamping: animationProperties.damping,
            initialSpringVelocity: 1,
            options: .allowUserInteraction,
            animations: {
                self.scrollView?.contentOffset = scrollTo
            },
            completion: nil
        )
    }

    weak var scrollView: UIScrollView?

    public init() {}

    public struct AnimationProperties {
        let duration: CGFloat
        let damping: CGFloat
        let offset: CGPoint

        public init(duration: CGFloat, damping: CGFloat, offset: CGPoint) {
            self.duration = duration
            self.damping = damping
            self.offset = offset
        }
    }
}

#Preview {
    let vm = SetOffsetViewModel()
    ScrollView(.horizontal) {
        HStack {
            Rectangle().frame(width: 100)
            Rectangle().frame(width: 100)
            Rectangle().frame(width: 100)
            Rectangle().frame(width: 100)
            Rectangle().frame(width: 100)
            Rectangle().frame(width: 100)
        }
    }
    .modifier(SetOffsetModifier(vm: vm))
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            vm.animate(with: .init(duration: 1, damping: 0.6, offset: .init(x: 600, y: 0)))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            vm.animate(with: .init(duration: 1, damping: 0.3, offset: .init(x: 50, y: 0)))
        }
    }
}
