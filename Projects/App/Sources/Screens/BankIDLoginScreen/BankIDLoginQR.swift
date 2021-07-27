import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct BankIDLoginQR {}

enum BankIDLoginQRResult {
    case loggedIn
}

extension BankIDLoginQR: Presentable {
	func materialize() -> (UIViewController, Signal<BankIDLoginQRResult>) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let view = UIView()
		view.backgroundColor = .brand(.primaryBackground())

		viewController.view = view
		viewController.title = L10n.bankidMissingTitle
		viewController.navigationItem.hidesBackButton = true

		let moreBarButtonItem = UIBarButtonItem(
			image: Asset.menuIcon.image,
			style: .plain,
			target: nil,
			action: nil
		)
		moreBarButtonItem.tintColor = .brand(.primaryText())

		viewController.navigationItem.rightBarButtonItem = moreBarButtonItem

		let containerStackView = UIStackView()
		containerStackView.axis = .vertical
		containerStackView.alignment = .center

		view.addSubview(containerStackView)

		containerStackView.snp.makeConstraints { make in make.leading.trailing.top.equalToSuperview() }

		let containerView = UIStackView()
		containerView.spacing = 15
		containerView.axis = .vertical
		containerView.alignment = .center
		containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
		containerView.isLayoutMarginsRelativeArrangement = true
		containerStackView.addArrangedSubview(containerView)

		let headerContainer = UIStackView()
		headerContainer.axis = .vertical
		headerContainer.spacing = 15

		containerView.addArrangedSubview(headerContainer)

		let iconContainerView = UIView()

		iconContainerView.snp.makeConstraints { make in make.height.width.equalTo(120) }

		let imageView = UIImageView()

		iconContainerView.addSubview(imageView)

		imageView.snp.makeConstraints { make in make.height.width.equalToSuperview() }

		headerContainer.addArrangedSubview(iconContainerView)

		let messageLabel = MultilineLabel(
			value: L10n.bankidMissingMessage,
			style: .brand(.headline(color: .primary))
		)
		bag += containerView.addArranged(messageLabel)

		func generateQRCode(_ url: URL) {
			let data = url.absoluteString.data(using: String.Encoding.ascii)
			guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
			qrFilter.setValue(data, forKey: "inputMessage")
			guard let qrImage = qrFilter.outputImage else { return }

			let transform = CGAffineTransform(scaleX: 10, y: 10)
			let scaledQrImage = qrImage.transformed(by: transform)

			guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return }
			maskToAlphaFilter.setValue(scaledQrImage, forKey: "inputImage")
			guard let outputCIImage = maskToAlphaFilter.outputImage else { return }

			let context = CIContext()
			guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
				return
			}
			let processedImage = UIImage(cgImage: cgImage)

			imageView.tintColor = .brand(.primaryText())
			imageView.backgroundColor = UIColor.brand(.secondaryBackground())
			imageView.image = processedImage.withRenderingMode(.alwaysTemplate)
		}

		bag += Signal(every: 10).atOnce().mapLatestToFuture { BankIDLoginSweden().generateAutoStartToken() }
			.transition(style: .crossDissolve(duration: 0.5), with: imageView, animations: generateQRCode)

        return (viewController, Signal { callback in
            
            bag += moreBarButtonItem.onValue { _ in
                let alert = Alert<Void>(actions: [
                    .init(
                        title: L10n.demoModeStart,
                        action: {
                            callback(.loggedIn)
                        }
                    ), .init(title: L10n.demoModeCancel, style: .cancel, action: {}),
                ])

                viewController.present(
                    alert,
                    style: .sheet(from: moreBarButtonItem.view, rect: moreBarButtonItem.view?.frame)
                )
            }
            
            return bag
        })
	}
}
