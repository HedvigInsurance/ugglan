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

struct UpperFormScroller<Content: View, BackgroundContent: View>: UIViewRepresentable, Equatable {
	let hostingController: IgnoredSafeAreaHostingController<AnyView>
	let backgroundHostingController: IgnoredSafeAreaHostingController<AnyView>
	var content: () -> Content
	var backgroundContent: () -> BackgroundContent
	@SwiftUI.Environment(\.presentableViewUpperScrollView) var upperScrollView
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

	func makeCoordinator() {
		return ()
	}

	func setSize() {
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
        
        if #available(iOS 14.0, *) {
            self.upperScrollView?.window?.overrideUserInterfaceStyle = .init(colorScheme)
        }
	}

	func makeUIView(context: Context) -> UIView {
		if upperScrollView == nil {
			fatalError("Must be used with an upper PresentableView")
		}

		setSize()
		self.upperScrollView?.addSubview(self.backgroundHostingController.view)

		if let upperScrollView = self.upperScrollView {
			self.backgroundHostingController.view.snp.makeConstraints { make in
				make.edges.equalTo(upperScrollView.frameLayoutGuide)
			}
            
            upperScrollView.alwaysBounceVertical = true
		}

		self.upperScrollView?.addSubview(self.hostingController.view)
		self.hostingController.view.backgroundColor = .clear

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
		setSize()
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
