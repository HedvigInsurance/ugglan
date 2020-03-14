//
//  BankIDLoginQR.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-05.
//

import Flow
import Foundation
import Presentation
import UIKit
import ComponentKit

struct BankIDLoginQR {
    let autoStartURL: URL
}

extension BankIDLoginQR: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: 350)
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .secondaryBackground

        viewController.view = view
        viewController.title = String(key: .BANKID_MISSING_TITLE)
        viewController.navigationItem.hidesBackButton = true

        let moreBarButtonItem = UIBarButtonItem(
            image: Asset.menuIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        moreBarButtonItem.tintColor = .navigationItemMutedTintColor

        bag += moreBarButtonItem.onValue { _ in
            let alert = Alert<Void>(actions: [
                .init(
                    title: String(key: .DEMO_MODE_START),
                    action: {
                        viewController.present(
                            LoggedIn(),
                            style: .modally(
                                presentationStyle: .overFullScreen,
                                transitionStyle: nil,
                                capturesStatusBarAppearance: true
                            ),
                            options: []
                        )
                    }
                ),
                .init(
                    title: String(key: .DEMO_MODE_CANCEL),
                    style: .cancel,
                    action: {}
                ),
            ])

            viewController.present(
                alert,
                style: .sheet(
                    from: moreBarButtonItem.view,
                    rect: moreBarButtonItem.view?.frame
                )
            )
        }

        viewController.navigationItem.rightBarButtonItem = moreBarButtonItem

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center

        bag += containerStackView.applySafeAreaBottomLayoutMargin()
        bag += containerStackView.applyPreferredContentSize(on: viewController)

        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

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

        iconContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(120)
        }

        let imageView = UIImageView()

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }

        headerContainer.addArrangedSubview(iconContainerView)

        let messageLabel = MultilineLabel(
            value: String(key: .BANKID_MISSING_MESSAGE),
            style: .rowTitle
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
            guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return }
            let processedImage = UIImage(cgImage: cgImage)

            imageView.tintColor = .primaryText
            imageView.backgroundColor = UIColor.secondaryBackground
            imageView.image = processedImage.withRenderingMode(.alwaysTemplate)
        }

        generateQRCode(autoStartURL)

        return (viewController, bag)
    }
}
