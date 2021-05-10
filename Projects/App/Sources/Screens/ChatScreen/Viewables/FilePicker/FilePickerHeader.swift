import Flow
import Form
import Foundation
import hCore
import Photos
import UIKit

struct FilePickerHeader {
    weak var uploadFileDelegate = Delegate<FileUpload, Future<(key: String, bucket: String)>>()
}

extension FilePickerHeader: Reusable {
	static func makeAndConfigure() -> (make: UIView, configure: (FilePickerHeader) -> Disposable) {
		let view = UIView()

		return (
			view, { `self` in let bag = DisposeBag()

				bag +=
					view.add(self) { buttonView in
						buttonView.snp.makeConstraints { make in
							make.width.height.equalToSuperview()
						}
					}
					.onValue { _ in }

				return bag
			}
		)
	}
}

extension FilePickerHeader: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<Void>) {
		let bag = DisposeBag()

		let containerView = UIStackView()
		containerView.axis = .vertical
		containerView.distribution = .fillEqually
		containerView.spacing = 5

		func processPickResult(_ result: Either<PHAsset, UIImage>) -> Disposable {
			let innerBag = DisposeBag()

			if let asset = result.left {
				asset.fileUpload
					.onValue { fileUpload in
						self.uploadFileDelegate.call(fileUpload)?.onValue { _ in }
					}
					.onError { error in log.error(error.localizedDescription) }
			} else if let image = result.right {
				guard let jpegData = image.jpegData(compressionQuality: 0.9) else {
					log.error("couldn't process image")
					return innerBag
				}

				let fileUpload = FileUpload(
					data: jpegData,
					mimeType: "image/jpeg",
					fileName: "image.jpg"
				)

				uploadFileDelegate.call(fileUpload)?.onValue { _ in }
			}

			return innerBag
		}

		let cameraButton = PickerButton(icon: Asset.camera.image)
		bag += containerView.addArranged(cameraButton)
			.onValueDisposePrevious { _ in
				containerView.viewController?
					.present(
						ImagePicker(sourceType: .camera, mediaTypes: [.video, .photo]),
						style: .modal,
						options: []
					)
					.valueSignal.onValueDisposePrevious(processPickResult)
			}

		let photoLibraryButton = PickerButton(icon: Asset.photoLibrary.image)
		bag += containerView.addArranged(photoLibraryButton)
			.onValueDisposePrevious { _ in
				containerView.viewController?
					.present(
						ImagePicker(sourceType: .photoLibrary, mediaTypes: [.video, .photo]),
						style: .modal,
						options: []
					)
					.valueSignal.onValueDisposePrevious(processPickResult)
			}

		let filesButton = PickerButton(icon: Asset.files.image)
		bag += containerView.addArranged(filesButton)
			.onValueDisposePrevious { _ in
				containerView.viewController?.present(DocumentPicker(), options: []).valueSignal
					.onValueDisposePrevious(on: .background) { urls -> Disposable in
						let fileUploads = urls.compactMap { url -> Future<FileUpload> in
							let fileCoordinator = NSFileCoordinator()

							return
								fileCoordinator.coordinate(
									readingItemAt: url,
									options: .withoutChanges
								)
								.map { data in
									FileUpload(
										data: data,
										mimeType: url.mimeType,
										fileName: url.path
									)
								}
						}

						return join(fileUploads).valueSignal
							.map { fileUploads -> [Disposable] in
								fileUploads.compactMap {
									self.uploadFileDelegate.call($0)?.valueSignal
										.onValue { _ in }
								}
							}
							.onValueDisposePrevious { list -> Disposable? in
								DisposeBag(list)
							}
					}
			}

		return (containerView, Signal<Void> { _ -> Disposable in bag })
	}
}
