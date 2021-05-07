import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit
import hCore

public struct Document {
	let url: URL
	let title: String

	public init(url: URL, title: String) {
		self.url = url
		self.title = title
	}
}

extension Document: Presentable {
	public func materialize() -> (UIViewController, Disposable) {
		let bag = DisposeBag()

		let viewController = UIViewController()
		viewController.title = title

		let pdfViewer = PDFViewer()
		bag += viewController.install(pdfViewer)

		pdfViewer.url.value = url

		let activityButton = UIBarButtonItem(system: .action)

		bag += viewController.navigationItem.addItem(activityButton, position: .right).withLatestFrom(
			pdfViewer.data
		).onValueDisposePrevious { _, value -> Disposable? in
			guard let value = value else { return NilDisposer() }

			let activityView = ActivityView(
				activityItems: [value],
				applicationActivities: nil,
				sourceView: activityButton.view,
				sourceRect: activityButton.bounds
			)

			let activityViewPresentation = Presentation(
				activityView,
				style: .activityView,
				options: .defaults
			)

			return viewController.present(activityViewPresentation).disposable
		}

		return (viewController, bag)
	}
}
