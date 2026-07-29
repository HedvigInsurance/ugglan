import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct HomeSheetContainer<Content: View>: View {
    /// How far the surface reaches past the safe area, i.e. how much of it the tab bar overlaps.
    private let bottomInset: CGFloat
    /// The sheet must always reach the screen bottom at rest.
    private let minHeight: CGFloat
    /// Taller content than this scrolls inside the surface instead of growing the sheet.
    private let maxHeight: CGFloat
    private let handoff: NestedScrollHandoff
    private let content: Content
    @State private var chipsHeight: CGFloat = 0
    @State private var grabberHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0

    init(
        bottomInset: CGFloat,
        minHeight: CGFloat,
        maxHeight: CGFloat,
        handoff: NestedScrollHandoff,
        @ViewBuilder content: () -> Content
    ) {
        self.bottomInset = bottomInset
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.handoff = handoff
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HomeActionChips()
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { chipsHeight = $0 }
            sheetSurface
        }
        // Hugs the content so the empty surface after the last item is only the safe-area
        // inset; the bounds keep the sheet reaching the screen bottom at rest and cap it
        // at the viewport so taller content scrolls inside.
        .frame(height: min(max(naturalHeight, minHeight), maxHeight), alignment: .top)
    }

    private var naturalHeight: CGFloat {
        chipsHeight + grabberHeight + contentHeight + bottomInset + surfaceBottomGap
    }

    private var surfaceShape: hRoundedRectangle {
        hRoundedRectangle(cornerRadius: .cornerRadiusXXL, corners: [.topLeft, .topRight])
    }

    private let surfaceBottomGap: CGFloat = .padding8

    private var sheetSurface: some View {
        VStack(spacing: 0) {
            grabber
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { grabberHeight = $0 }
            sheetScrollView
        }
        .padding(.bottom, surfaceBottomGap)
        .frame(maxWidth: .infinity)
        .clipShape(surfaceShape)
        .background {
            surfaceShape
                .fill(hBackgroundColor.primary)
                .hShadow(type: .light)
        }
    }

    private var sheetScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            content
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { contentHeight = $0 }
                .padding(.bottom, bottomInset)
        }
        // The card pagers inside switch their own clipping off and paint outside their bounds.
        // The surface's corner clip starts above the grabber, so only this stops them.
        .clipped()
        .introspect(.scrollView, on: .iOS(.v16...)) { scrollView in
            handoff.connect(inner: scrollView)
        }
    }

    private var grabber: some View {
        Capsule()
            .fill(hSurfaceColor.Opaque.secondary)
            .frame(width: 40, height: 4)
            .padding(.top, .padding8)
            .padding(.bottom, .padding4)
            .accessibilityHidden(true)
    }
}

/// Outer-first scroll delegation between the home's root scroll view and the sheet's inner one.
/// iOS has no built-in chaining between sibling scroll views — the inner always wins the pan — so
/// the inner's offset delta is rolled into the outer until the outer is exhausted, and rolled back
/// on the way down. Momentum carries across the handoff because forwarding happens per offset event.
@MainActor
final class NestedScrollHandoff {
    private weak var outer: UIScrollView?
    private weak var inner: UIScrollView?
    private var innerObservation: AnyCancellable?
    /// A transfer writes contentOffset, which re-enters this observer.
    private var isForwarding = false

    func connect(outer scrollView: UIScrollView) {
        guard scrollView !== outer else { return }
        outer = scrollView
        startObserving()
    }

    func connect(inner scrollView: UIScrollView) {
        guard scrollView !== inner else { return }
        inner = scrollView
        startObserving()
    }

    /// KVO on contentOffset is the only offset source left on iOS 26+: scrolling is pure layer
    /// translation there, so geometry readers never fire.
    private func startObserving() {
        guard let inner, outer != nil else { return }
        innerObservation = inner.publisher(for: \.contentOffset)
            .sink { [weak self] offset in
                MainActor.assumeIsolated {
                    self?.forward(innerOffset: offset.y)
                }
            }
    }

    private var outerMaxOffset: CGFloat {
        guard let outer else { return 0 }
        return outer.contentSize.height + outer.adjustedContentInset.bottom - outer.bounds.height
    }

    private var innerContentFits: Bool {
        guard let inner else { return false }
        let insets = inner.adjustedContentInset
        return inner.contentSize.height + insets.top + insets.bottom <= inner.bounds.height
    }

    private func forward(innerOffset: CGFloat) {
        guard !isForwarding, let outer, let inner else { return }

        let restingOffset = -outer.adjustedContentInset.top
        let roomUp = outerMaxOffset - outer.contentOffset.y
        let roomDown = outer.contentOffset.y - restingOffset

        isForwarding = true
        defer { isForwarding = false }

        if innerOffset > 0 {
            if roomUp > 0 {
                let transfer = min(innerOffset, roomUp)
                outer.contentOffset.y += transfer
                inner.contentOffset.y = innerOffset - transfer
            } else if innerContentFits {
                // Docked with everything visible: dragging further does nothing at all.
                inner.contentOffset.y = 0
            }
        } else if innerOffset < 0, roomDown > 0 {
            let transfer = max(innerOffset, -roomDown)
            outer.contentOffset.y += transfer
            inner.contentOffset.y = 0
        }
    }
}

@MainActor private func setUpHomeSheetContainerPreview() {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
}

#Preview {
    setUpHomeSheetContainerPreview()

    return HomeSheetContainer(bottomInset: 0, minHeight: 400, maxHeight: 800, handoff: NestedScrollHandoff()) {
        VStack(spacing: .padding16) {
            ForEach(0..<12, id: \.self) { index in
                hSection {
                    hRow { hText("Row \(index)") }
                }
            }
        }
        .padding(.top, .padding16)
        .padding(.bottom, .padding40)
    }
    .environmentObject(HomeNavigationViewModel())
}
