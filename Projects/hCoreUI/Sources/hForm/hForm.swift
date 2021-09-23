import Combine
import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

/// Fix for UIHostingController always using SafeAreaInsets
class IgnoredSafeAreaHostingController<Content: SwiftUI.View>: UIHostingController<Content> {
    func apply() -> Self {
        self.fixSafeAreaInsets()
        return self
    }

    func fixSafeAreaInsets() {
        guard let _class = view?.classForCoder else {
            fatalError()
        }

        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = {
            (sself: AnyObject!) -> UIEdgeInsets in
            return .zero
        }
        guard
            let safeAreaInsetsMethod = class_getInstanceMethod(
                _class.self,
                #selector(getter:UIView.safeAreaInsets)
            )
        else {
            return
        }
        class_replaceMethod(
            _class,
            #selector(getter:UIView.safeAreaInsets),
            imp_implementationWithBlock(safeAreaInsets),
            method_getTypeEncoding(safeAreaInsetsMethod)
        )

        let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = {
            (sself: AnyObject!) -> UILayoutGuide? in return nil
        }

        guard
            let safeAreaLayoutGuideMethod = class_getInstanceMethod(
                _class.self,
                #selector(getter:UIView.safeAreaLayoutGuide)
            )
        else { return }
        class_replaceMethod(
            _class,
            #selector(getter:UIView.safeAreaLayoutGuide),
            imp_implementationWithBlock(safeAreaLayoutGuide),
            method_getTypeEncoding(safeAreaLayoutGuideMethod)
        )
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
}

private struct EnvironmentHFormBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hFormBottomAttachedView: AnyView? {
        get { self[EnvironmentHFormBottomAttachedView.self] }
        set { self[EnvironmentHFormBottomAttachedView.self] = newValue }
    }
}

struct UpperFormScroller<Content: View, BackgroundContent: View>: UIViewRepresentable, Equatable {
    let hostingController: IgnoredSafeAreaHostingController<AnyView>
    let backgroundHostingController: IgnoredSafeAreaHostingController<AnyView>
    var content: () -> Content
    var backgroundContent: () -> BackgroundContent
    @SwiftUI.Environment(\.presentableViewUpperScrollView) var upperScrollView
    @SwiftUI.Environment(\.hFormBottomAttachedView) var bottomAttachedView
    @SwiftUI.Environment(\.userInterfaceLevel) var userInterfaceLevel
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    init(
        @ViewBuilder backgroundContent: @escaping () -> BackgroundContent,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hostingController = IgnoredSafeAreaHostingController(rootView: AnyView(EmptyView())).apply()
        self.backgroundHostingController = IgnoredSafeAreaHostingController(rootView: AnyView(EmptyView()))
            .apply()
        self.backgroundContent = backgroundContent
        self.content = content
    }

    class Coordinator {
        var bottomAttachedHostingView: HostingView<AnyView>? = nil
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func setSize(context: Context) {
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()

        let width: CGFloat = (self.upperScrollView?.frame.width ?? 0)

        let contentSize: CGSize = self.hostingController.view.systemLayoutSizeFitting(
            CGSize(width: width, height: .infinity)
        )
        
        self.hostingController.view.frame.size = contentSize
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()

        self.upperScrollView?.contentSize = contentSize
        self.upperScrollView?.updateConstraintsIfNeeded()
        self.upperScrollView?.layoutIfNeeded()

        if let upperScrollView = self.upperScrollView,
            let bottomAttachedHostingView = context.coordinator.bottomAttachedHostingView
        {
            bottomAttachedHostingView.frame.size = contentSize
            bottomAttachedHostingView.setNeedsLayout()
            bottomAttachedHostingView.layoutIfNeeded()

            let size = bottomAttachedHostingView.systemLayoutSizeFitting(upperScrollView.frame.size)
            upperScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
            upperScrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)

            bottomAttachedHostingView.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(upperScrollView.frameLayoutGuide)
                make.bottom.equalTo(upperScrollView.frameLayoutGuide)
            }
        }

        /// Override window userInterfacestyle if it doesn't match hForm's colorScheme
        if #available(iOS 14.0, *) {
            let style = self.upperScrollView?.window?.traitCollection.userInterfaceStyle

            if style == .dark && colorScheme == .light {
                self.upperScrollView?.window?.overrideUserInterfaceStyle = .light
            }

            if style == .light && colorScheme == .dark {
                self.upperScrollView?.window?.overrideUserInterfaceStyle = .dark
            }
        }
    }

    func makeUIView(context: Context) -> UIView {
        if upperScrollView == nil {
            fatalError("Must be used with an upper PresentableView")
        }

        self.upperScrollView?.addSubview(self.backgroundHostingController.view)
        self.upperScrollView?.addSubview(self.hostingController.view)
        
        self.hostingController.view.backgroundColor = .clear
        self.hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        if let upperScrollView = self.upperScrollView {
            self.backgroundHostingController.view.snp.makeConstraints { make in
                make.edges.equalTo(upperScrollView.frameLayoutGuide)
            }
            
            self.hostingController.view.snp.makeConstraints { make in
                make.trailing.leading.equalTo(upperScrollView.frameLayoutGuide)
            }

            upperScrollView.alwaysBounceVertical = true
        }
        
        if let bottomAttachedView = bottomAttachedView {
            let hostingView = HostingView(
                rootView: AnyView(bottomAttachedView.modifier(TransferEnvironment(environment: context.environment)))
            )
            context.coordinator.bottomAttachedHostingView = hostingView
            self.upperScrollView?.addSubview(hostingView)
        }

        setSize(context: context)

        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        backgroundHostingController.rootView = AnyView(
            backgroundContent()
                .modifier(TransferEnvironment(environment: context.environment))
                .environment(\.presentableViewUpperScrollView, upperScrollView)
        )
        self.backgroundHostingController.view.setNeedsUpdateConstraints()
        self.backgroundHostingController.view.setNeedsLayout()
        self.backgroundHostingController.view.layoutIfNeeded()

        self.hostingController.rootView = AnyView(
            content()
                .modifier(TransferEnvironment(environment: context.environment))
                .environment(\.presentableViewUpperScrollView, upperScrollView)
        )
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()
        setSize(context: context)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.userInterfaceLevel == rhs.userInterfaceLevel && lhs.colorScheme == rhs.colorScheme
    }
}

struct WidthConstrainer: ViewModifier {
    @Environment(\.presentableViewUpperScrollView) var upperScrollView

    func body(content: Content) -> some View {
        content.frame(maxWidth: upperScrollView?.frame.width ?? 0)
    }
}

extension View {
    public func hFormAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hFormBottomAttachedView, AnyView(content()))
    }
}

public struct hForm<Content: View>: View {
    var content: Content

    public init(
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
    }

    public var body: some View {
        UpperFormScroller(backgroundContent: {
            Rectangle().fill(hBackgroundColor.primary).frame(maxWidth: .infinity, maxHeight: .infinity)
        }) {
            VStack {
                content
            }
            .frame(maxWidth: .infinity)
            .tint(hTintColor.lavenderOne)
        }
    }
}
