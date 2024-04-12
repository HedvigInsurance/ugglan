import Foundation
import SwiftUI

struct ContentSizeModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {

    @Binding var presented: Bool
    @State private var height: CGFloat = 0
    @State private var detents: Set<PresentationDetent> = []
    @State private var selected: PresentationDetent
    @StateObject private var vm = ContentSizeModifierViewModel()
    let content: SwiftUIContent
    private let style: DetentPresentationStyle

    init(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        @ViewBuilder content: @escaping () -> SwiftUIContent
    ) {
        _presented = presented
        self.content = content()

        var startDetents = Set<PresentationDetent>()
        if style.contains(.medium) {
            startDetents.insert(.medium)
        }
        if style.contains(.large) {
            startDetents.insert(.large)
        }

        if style.contains(.height) {
            startDetents.insert(.height(0))
        }
        self._detents = State(initialValue: startDetents)
        self._selected = State(initialValue: startDetents.first!)
        self.style = style
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $presented) {
                self.content
                    .presentationDetents(detents, selection: $selected)
                    .onChange(of: height) { newValue in
                        handleOnHeightChange(height: newValue)
                    }
                    .introspectScrollView { scrollView in
                        handleScrollView(scrollView: scrollView)
                    }

            }
            .onChange(of: presented) { newValue in
                if !presented {
                    vm.observer = nil
                }
            }
    }

    private func handleScrollView(scrollView: UIScrollView) {
        if self.style.contains(.height) {
            let scrollViewHeight = scrollView.contentSize.height
            let navBarHeight: CGFloat = {
                if scrollView.viewController?.navigationController?.isNavigationBarHidden == true {
                    return 0
                }
                return scrollView.viewController?.navigationController?.navigationBar.frame.size.height ?? 0
            }()
            DispatchQueue.main.async { [weak scrollView, weak vm] in guard let scrollView = scrollView else { return }
                vm?.observer = scrollView.observe(\UIScrollView.contentSize) { scrollView, changes in
                    DispatchQueue.main.async { [weak scrollView] in guard let scrollView = scrollView else { return }
                        withAnimation(.easeInOut(duration: 1)) {
                            height = scrollView.contentSize.height + navBarHeight
                        }
                    }
                }
                height = scrollViewHeight + navBarHeight
                scrollView.bounces = false
            }
        }
    }

    private func handleOnHeightChange(height: CGFloat) {
        let detent = detents.first { detent in
            detent != .medium || detent != .large
        }
        if !detents.contains(.height(height)) {
            detents.insert(.height(height))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            selected = .height(height)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let detent {
                detents.remove(detent)
            }
        }
    }
}

class ContentSizeModifierViewModel: ObservableObject {
    weak var observer: NSKeyValueObservation?
}

extension View {
    public func presentModally<SwiftUIContent: View>(
        presented: Binding<Bool>,
        style: DetentPresentationStyle,
        content: @escaping () -> SwiftUIContent
    ) -> some View {
        modifier(ContentSizeModifier(presented: presented, style: style, content: content))
    }
}

public struct DetentPresentationStyle: OptionSet {
    public let rawValue: UInt
    public static let medium = DetentPresentationStyle(rawValue: 1 << 0)
    public static let large = DetentPresentationStyle(rawValue: 1 << 1)
    public static let height = DetentPresentationStyle(rawValue: 1 << 2)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}
