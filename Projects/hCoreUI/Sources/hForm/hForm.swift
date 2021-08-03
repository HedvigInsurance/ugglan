import Combine
import Foundation
import SwiftUI
import UIKit
import hCore

struct FormScroller<Content: View>: UIViewControllerRepresentable, Equatable {
	typealias UIViewControllerType = FormScrollViewController<Content>

	var showsScrollIndicator: Bool
	var axis: Axis
	var content: () -> Content
	var disableScroll: Bool
	var forceRefresh: Bool
	var stopScrolling: Binding<Bool>
	private let scrollViewController: UIViewControllerType

	init(
		showsScrollIndicator: Bool = true,
		axis: Axis = .vertical,
		disableScroll: Bool = false,
		forceRefresh: Bool = false,
		stopScrolling: Binding<Bool> = .constant(false),
		@ViewBuilder content: @escaping () -> Content
	) {
		self.content = content
		self.showsScrollIndicator = showsScrollIndicator
		self.axis = axis
		self.disableScroll = disableScroll
		self.forceRefresh = forceRefresh
		self.stopScrolling = stopScrolling
		self.scrollViewController = FormScrollViewController(
			rootView: self.content(),
			axis: self.axis
		)
	}

	func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {
		self.scrollViewController
	}

	func updateUIViewController(
		_ viewController: UIViewControllerType,
		context: UIViewControllerRepresentableContext<Self>
	) {
		viewController.scrollView.showsVerticalScrollIndicator = self.showsScrollIndicator
		viewController.scrollView.showsHorizontalScrollIndicator = self.showsScrollIndicator
		viewController.updateContent(self.content)
		viewController.scrollView.isScrollEnabled = !self.disableScroll
	}

	func makeCoordinator() -> Coordinator {
		()
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.forceRefresh != rhs.forceRefresh
	}
}

final class FormScrollViewController<Content: View>: UIViewController, ObservableObject {
	let hostingController: UIHostingController<Content>
	let axis: Axis

	lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.canCancelContentTouches = true
		scrollView.delaysContentTouches = true
		scrollView.scrollsToTop = false
		scrollView.backgroundColor = .clear

		return scrollView
	}()

	init(
		rootView: Content,
		axis: Axis
	) {
		self.hostingController = UIHostingController<Content>(rootView: rootView)
		self.hostingController.view.backgroundColor = .clear
		self.axis = axis
		super.init(nibName: nil, bundle: nil)
	}

	func updateContent(_ content: () -> Content) {
		self.hostingController.rootView = content()
		self.scrollView.addSubview(self.hostingController.view)

		var contentSize: CGSize = self.hostingController.view.intrinsicContentSize

		switch axis {
		case .vertical:
			contentSize.width = self.scrollView.frame.width
		case .horizontal:
			contentSize.height = self.scrollView.frame.height
		}

		self.hostingController.view.frame.size = contentSize
		self.scrollView.contentSize = contentSize
		self.view.updateConstraintsIfNeeded()
		self.view.layoutIfNeeded()
	}

	required init?(
		coder: NSCoder
	) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(self.scrollView)
		self.scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		self.view.setNeedsUpdateConstraints()
		self.view.updateConstraintsIfNeeded()
		self.view.layoutIfNeeded()
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
		FormScroller {
			VStack {
				content
			}
			.frame(maxWidth: .infinity)
		}
		.background(
			Color(UIColor(base: .brand(.primaryBackground()), elevated: .brand(.secondaryBackground())))
		)
	}
}
