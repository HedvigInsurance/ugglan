import Foundation
import SwiftUI
import UIKit

public class HostingView<Content: View>: UIView {
    let rootViewHostingController: AdjustableHostingController<Content>

    public var swiftUIRootView: Content {
        get {
            self.rootViewHostingController.rootView
        }
        set {
            self.rootViewHostingController.rootView = newValue
        }
    }

    public required init(
        rootView: Content
    ) {

        self.rootViewHostingController = .init(rootView: rootView)

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
        fixSafeAreaInsets()
    }

    @MainActor @objc required dynamic init?(
        coder aDecoder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    func fixSafeAreaInsets() {
        guard let _class = view?.classForCoder else {
            fatalError()
        }

        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { (sself: AnyObject!) -> UIEdgeInsets in
            return .zero
        }
        guard let method = class_getInstanceMethod(_class.self, #selector(getter:UIView.safeAreaInsets)) else { return }
        class_replaceMethod(
            _class,
            #selector(getter:UIView.safeAreaInsets),
            imp_implementationWithBlock(safeAreaInsets),
            method_getTypeEncoding(method)
        )

        let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = {
            (sself: AnyObject!) -> UILayoutGuide? in return nil
        }

        guard let method2 = class_getInstanceMethod(_class.self, #selector(getter:UIView.safeAreaLayoutGuide)) else {
            return
        }
        class_replaceMethod(
            _class,
            #selector(getter:UIView.safeAreaLayoutGuide),
            imp_implementationWithBlock(safeAreaLayoutGuide),
            method_getTypeEncoding(method2)
        )
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.view.invalidateIntrinsicContentSize()
    }
}
