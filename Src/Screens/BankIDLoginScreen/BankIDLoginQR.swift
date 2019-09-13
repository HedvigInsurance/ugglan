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

struct BankIDLoginQR {
    let autoStartURL: URL
}

extension BankIDLoginQR: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        view.backgroundColor = .red

        viewController.view = view
        viewController.title = "BankID saknas på din enhet"
        viewController.navigationItem.hidesBackButton = true

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

        let messageLabel = MultilineLabel(value: "Skanna QR-koden ovan i den enhet där du har BankID installerat.", style: .rowTitle)
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

            imageView.tintColor = UIColor.white
            imageView.backgroundColor = UIColor.secondaryBackground
            imageView.image = processedImage.withRenderingMode(.alwaysTemplate)
        }

        generateQRCode(autoStartURL)

        return (viewController, bag)
    }
}
