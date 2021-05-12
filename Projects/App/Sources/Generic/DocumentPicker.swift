import Flow
import Foundation
import Presentation
import UIKit

struct DocumentPicker {}

private var didPickDocumentsCallbackerKey = 0
private var didCancelDocumentPickerCallbackerKey = 1

extension UIDocumentPickerViewController: UIDocumentPickerDelegate {
	private var didPickDocumentsCallbacker: Callbacker<[URL]> {
		if let callbacker = objc_getAssociatedObject(self, &didPickDocumentsCallbackerKey) as? Callbacker<[URL]> {
			return callbacker
		}

		delegate = self

		let callbacker = Callbacker<[URL]>()

		objc_setAssociatedObject(
			self,
			&didPickDocumentsCallbackerKey,
			callbacker,
			.OBJC_ASSOCIATION_RETAIN_NONATOMIC
		)

		return callbacker
	}

	private var didCancelDocumentPickerCallbacker: Callbacker<Void> {
		if let callbacker = objc_getAssociatedObject(self, &didCancelDocumentPickerCallbackerKey)
			as? Callbacker<Void> {
			return callbacker
		}

		delegate = self

		let callbacker = Callbacker<Void>()

		objc_setAssociatedObject(
			self,
			&didCancelDocumentPickerCallbackerKey,
			callbacker,
			.OBJC_ASSOCIATION_RETAIN_NONATOMIC
		)

		return callbacker
	}

	var didPickDocumentsSignal: Signal<[URL]> { didPickDocumentsCallbacker.providedSignal }

	var didCancelSignal: Signal<Void> { didCancelDocumentPickerCallbacker.providedSignal }

	public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		didPickDocumentsCallbacker.callAll(with: urls)
	}

	public func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
		didCancelDocumentPickerCallbacker.callAll()
	}
}

enum DocumentPickerError: Error { case cancelled }

extension DocumentPicker: Presentable {
	func materialize() -> (UIDocumentPickerViewController, Future<[URL]>) {
		let viewController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
		viewController.allowsMultipleSelection = true
		viewController.preferredPresentationStyle = .modally(
			presentationStyle: .formSheet,
			transitionStyle: nil,
			capturesStatusBarAppearance: nil
		)

		return (
			viewController,
			Future { completion in let bag = DisposeBag()

				bag += viewController.didPickDocumentsSignal.onValue { urls in
					completion(.success(urls))
				}

				bag += viewController.didCancelSignal.onValue { _ in
					completion(.failure(DocumentPickerError.cancelled))
				}

				return bag
			}
		)
	}
}
