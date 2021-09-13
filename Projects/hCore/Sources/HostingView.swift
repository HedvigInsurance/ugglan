import Foundation
import SwiftUI
import UIKit

public class HostingView<Content: View>: UIView {
    let rootViewHostingController: UIHostingController<Content>
    
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

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
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
