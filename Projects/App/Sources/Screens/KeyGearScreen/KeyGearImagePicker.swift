import Flow
import Foundation
import hCore
import Photos
import Presentation
import UIKit

struct KeyGearImagePicker: Presentable {
	let presentingViewController: UIViewController
	let allowedTypes: [PickType]

	enum PickType { case camera, photoLibrary, document }

	private var actions: [Alert<PickType>.Action] {
		let actions = allowedTypes.map { pickType -> Alert<PickType>.Action in
			switch pickType {
			case .camera:
				return Alert.Action(
					title: L10n.keyGearImagePickerCamera,
					style: .default,
					action: { _ in .camera }
				)
			case .photoLibrary:
				return Alert.Action(
					title: L10n.keyGearImagePickerPhotoLibrary,
					style: .default,
					action: { _ in .photoLibrary }
				)
			case .document:

				return Alert.Action(
					title: L10n.keyGearImagePickerDocument,
					style: .default,
					action: { _ in .document }
				)
			}
		}

		return [
			actions,
			[
				Alert.Action(
					title: L10n.keyGearImagePickerCancel,
					style: .cancel,
					action: { _ in throw GenericError.cancelled }
				)
			]
		]
		.flatMap { $0 }
	}

	func materialize() -> (UIViewController, Future<Either<Future<Either<PHAsset, UIImage>>, Future<[URL]>>>) {
		let (viewController, alertResult) = Alert<PickType>(actions: actions).materialize()

		return (
			viewController,
			Future { completion in
				alertResult.onValue { result in
					switch result {
					case .camera:
						completion(
							.success(
								.left(
									self.presentingViewController.present(
										ImagePicker(
											sourceType: .camera,
											mediaTypes: [.photo]
										),
										style: .default
									)
								)
							)
						)
					case .photoLibrary:
						completion(
							.success(
								.left(
									self.presentingViewController.present(
										ImagePicker(
											sourceType: .photoLibrary,
											mediaTypes: [.photo]
										),
										style: .default
									)
								)
							)
						)
					case .document:
						completion(
							.success(
								.right(
									self.presentingViewController.present(
										DocumentPicker(),
										style: .default
									)
								)
							)
						)
					}
				}
				.onError { error in completion(.failure(error)) }

				return NilDisposer()
			}
		)
	}
}
