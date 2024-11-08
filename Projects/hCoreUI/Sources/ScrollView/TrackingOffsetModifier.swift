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
    var scrollOffsetCancellable: AnyCancellable?
    @Published public var currentOffset: CGPoint = .zero

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
