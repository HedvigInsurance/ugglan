import Foundation
import Presentation
import SwiftUI
import UIKit

@propertyWrapper
public struct PresentableStore<S: Store> {
	public var wrappedValue: S { globalPresentableStoreContainer.get() }

	public init() {}
}

public protocol PresentableView: View, Presentable {
	var result: Result { get }
}

extension PresentableView {
	public func materialize() -> (ViewHostingController<Self>, Result) {
		let viewController = ViewHostingController(
			rootView: self
		)
		return (viewController, result)
	}
}

private struct EnvironmentNavigationItem: EnvironmentKey {
	static let defaultValue: UINavigationItem? = nil
}

extension EnvironmentValues {
	var navigationItem: UINavigationItem? {
		get { self[EnvironmentNavigationItem.self] }
		set { self[EnvironmentNavigationItem.self] = newValue }
	}
}

public struct PresentableViewNavigationBarConfigurer: ViewModifier {
	@SwiftUI.Environment(\.navigationItem) var navigationItem: UINavigationItem?
	var configurer: (_ navigationItem: UINavigationItem) -> Void

	public init(
		_ configurer: @escaping (_ navigationItem: UINavigationItem) -> Void
	) {
		self.configurer = configurer
	}

	public func body(content: Content) -> some View {
		content
			.onAppear {
				if let navigationItem = navigationItem {
					configurer(navigationItem)
					navigationItem.largeTitleDisplayMode = .always
				}
			}
	}
}

extension View {
	public func presentableTitle(_ title: String) -> some View {
		self.modifier(
			PresentableViewNavigationBarConfigurer({ navigationItem in
				navigationItem.title = title
			})
		)
	}
}

public class ViewHostingController<RootView: View>: UIViewController {
	let hostingController: UIHostingController<AnyView>

	init(
		rootView: RootView
	) {
		self.hostingController = UIHostingController(rootView: AnyView(EmptyView()))
		super.init(nibName: nil, bundle: nil)

		self.hostingController.rootView = AnyView(rootView.environment(\.navigationItem, self.navigationItem))
	}

	required init?(
		coder: NSCoder
	) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		self.addChild(hostingController)
		view.addSubview(hostingController.view)
		hostingController.didMove(toParent: self)

		hostingController.view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
}
