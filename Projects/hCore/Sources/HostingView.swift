import Foundation
import SnapKit
import SwiftUI

struct SafeAreaEdgesModifier: ViewModifier {
    var edgesIgnoringSafeArea: Edge.Set?

    func body(content: Content) -> some View {
        if let edgesIgnoringSafeArea = edgesIgnoringSafeArea {
            content.edgesIgnoringSafeArea(edgesIgnoringSafeArea)
        } else {
            content
        }
    }
}

public class HostingView<Content: View>: UIView {
    let edgesIgnoringSafeArea: Edge.Set?
    let rootViewHostingController: AdjustableHostingController<AnyView>

    public var swiftUIRootView: Content {
        didSet {
            self.rootViewHostingController.rootView = AnyView(
                swiftUIRootView.modifier(
                    SafeAreaEdgesModifier(edgesIgnoringSafeArea: edgesIgnoringSafeArea)
                )
            )
        }
    }

    public required init(
        rootView: Content,
        edgesIgnoringSafeArea: Edge.Set? = .all
    ) {
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
        self.swiftUIRootView = rootView
        self.rootViewHostingController = .init(
            rootView: AnyView(
                rootView.modifier(
                    SafeAreaEdgesModifier(edgesIgnoringSafeArea: edgesIgnoringSafeArea)
                )
            )
        )

        super.init(frame: .zero)

        rootViewHostingController.view.backgroundColor = .clear

        addSubview(rootViewHostingController.view)

        rootViewHostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        if let viewController = newSuperview?.viewController {
            viewController.addChild(rootViewHostingController)
            rootViewHostingController.didMove(toParent: viewController)
        }

        super.willMove(toSuperview: newSuperview)
    }

    deinit {
        rootViewHostingController.removeFromParent()
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        rootViewHostingController.view.sizeThatFits(targetSize)
    }

    public override var intrinsicContentSize: CGSize {
        if let superview = superview {
            if let scrollView = superview as? UIScrollView {
                return rootViewHostingController.view.sizeThatFits(scrollView.contentSize)
            }

            return rootViewHostingController.view.sizeThatFits(.zero)
        } else {
            return rootViewHostingController.view.sizeThatFits(.zero)
        }
    }

    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }

    override open func sizeToFit() {
        if let superview = superview {
            frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
        } else {
            frame.size = rootViewHostingController.sizeThatFits(in: .zero)
        }
    }
}

public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize = .zero

    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public class AdjustableHostingController<Content: View>: UIHostingController<Content> {
    public override init(
        rootView: Content
    ) {
        super.init(rootView: rootView)

        view.backgroundColor = .clear
    }

    @MainActor @objc required dynamic init?(
        coder aDecoder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.view.invalidateIntrinsicContentSize()
    }
}

/// Builds a view and wraps it in a hosting view
public func makeHost<RootView: View>(@ViewBuilder _ build: () -> RootView) -> HostingView<RootView> {
    HostingView(rootView: build())
}