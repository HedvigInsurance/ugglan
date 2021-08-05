import Combine
import Foundation
import SwiftUI
import UIKit
import hCore
import Flow

class IgnoredSafeAreaHostingController<Content: SwiftUI.View>: UIHostingController<Content> {
    func apply() -> Self {
        self.fixSafeAreaInsets()
        return self
    }

    func fixSafeAreaInsets() {
        guard let _class = view?.classForCoder else {
            fatalError()
        }

        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { (sself: AnyObject!) -> UIEdgeInsets in
            return .zero
        }
        guard let method = class_getInstanceMethod(_class.self, #selector(getter: UIView.safeAreaInsets)) else { return }
        class_replaceMethod(_class, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))

        let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = { (sself : AnyObject!) -> UILayoutGuide? in return nil }

        guard let method2 = class_getInstanceMethod(_class.self, #selector(getter: UIView.safeAreaLayoutGuide)) else { return }
        class_replaceMethod(_class, #selector(getter: UIView.safeAreaLayoutGuide), imp_implementationWithBlock(safeAreaLayoutGuide), method_getTypeEncoding(method2))
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
}

struct UpperFormScroller<Content: View>: UIViewRepresentable, Equatable {
	let hostingController: IgnoredSafeAreaHostingController<AnyView>
	var content: () -> Content
	@SwiftUI.Environment(\.presentableViewUpperScrollView) var upperScrollView

	init(
		@ViewBuilder content: @escaping () -> Content
	) {
        self.hostingController = IgnoredSafeAreaHostingController(rootView: AnyView(EmptyView())).apply()
		self.content = content
	}

	func makeCoordinator() {
		return ()
	}
    
    func setSize() {
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()
        
        var contentSize: CGSize = self.hostingController.view.systemLayoutSizeFitting(CGSize(width: self.upperScrollView?.frame.width ?? 0, height: .infinity))
        contentSize.width = self.upperScrollView?.frame.width ?? 0

        self.hostingController.view.frame.size = contentSize
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()
        
        self.upperScrollView?.contentSize = contentSize
        self.upperScrollView?.updateConstraintsIfNeeded()
        self.upperScrollView?.layoutIfNeeded()
    }

	func makeUIView(context: Context) -> UIView {
		if upperScrollView == nil {
			fatalError("Must be used with an upper PresentableView")
		}

        setSize()
		self.upperScrollView?.addSubview(self.hostingController.view)
		self.hostingController.view.backgroundColor = .clear
		self.upperScrollView?.backgroundColor = UIColor(
			base: .brand(.primaryBackground()),
			elevated: .brand(.secondaryBackground())
		)
        
		return UIView()
	}

	func updateUIView(_ uiView: UIView, context: Context) {
        self.hostingController.rootView = AnyView(content().environment(\.presentableViewUpperScrollView, upperScrollView))
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()
        setSize()
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
        return true
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
		UpperFormScroller {
            VStack {
                content
            }
            .frame(maxWidth: .infinity)
		}
	}
}
