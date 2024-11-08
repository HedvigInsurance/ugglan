import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct TrackingOffsetModifier: ViewModifier {
    @StateObject var vm = TracingOffsetViewModel()
    @Binding var offset: CGPoint

    public init(
        offset: Binding<CGPoint>
    ) {
        self._offset = offset
    }

    public func body(content: Content) -> some View {
        content
            .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                if vm.scrollView != scrollView {
                    vm.scrollView = scrollView
                }
            }
            .onChange(of: vm.currentOffset) { newOffset in
                offset = newOffset
            }
    }
}

class TracingOffsetViewModel: ObservableObject {
    var scrollOffsetCancellable: AnyCancellable?
    @Published var currentOffset: CGPoint = .zero

    weak var scrollView: UIScrollView? {
        didSet {
            scrollOffsetCancellable = scrollView?.publisher(for: \.contentOffset).receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] offset in
                    self?.currentOffset = offset
                })
        }
    }

    init() {}
}
