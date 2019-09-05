//
//  BankIDLogin.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-05.
//

import Foundation
import Presentation
import UIKit
import Flow
import Apollo
import Form

struct BankIDLogin {
    let client: ApolloClient
    
    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension BankIDLogin: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let view = UIView()
        viewController.view = view

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
        imageView.image = Asset.bankIdLogo.image
        imageView.tintColor = .primaryText

        iconContainerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }

        headerContainer.addArrangedSubview(iconContainerView)

        bag += headerContainer.addArranged(LoadingIndicator(showAfter: 0, size: 50).wrappedIn(UIStackView()))

        let statusLabel = MultilineLabel(value: String(key: .SIGN_START_BANKID), style: .rowTitle)
        bag += containerView.addArranged(statusLabel)

        let closeButtonContainer = UIStackView()
        closeButtonContainer.animationSafeIsHidden = true
        containerView.addArrangedSubview(closeButtonContainer)

        let closeButton = Button(title: "Stäng", type: .standard(backgroundColor: .purple, textColor: .white))
        bag += closeButtonContainer.addArranged(closeButton)

        let statusSignal = client.subscribe(
            subscription: BankIdAuthSubscription()
        ).compactMap { $0.data?.authStatus?.status }
        
        let hasBankIDInstalledSignal = ReadWriteSignal<Bool?>(nil)
        
        bag += statusSignal.skip(first: 1).withLatestFrom(hasBankIDInstalledSignal.plain()).onValue { authStatus, hasBankIDInstalled in
            guard let hasBankIDInstalled = hasBankIDInstalled else {
                return
            }
            let statusText: String

            switch authStatus {
            case .initiated:
                if hasBankIDInstalled {
                    statusText = String(key: .BANK_ID_AUTH_TITLE_INITIATED)
                } else {
                    statusText = "Skanna koden ovan med BankID appen på den telefonen där du har det installerat"
                }
            case .inProgress:
                statusText = String(key: .BANK_ID_AUTH_TITLE_INITIATED)
            case .failed:
                statusText = String(key: .BANK_ID_AUTH_TITLE_INITIATED)
            case .success:
                statusText = String(key: .BANK_ID_AUTH_TITLE_INITIATED)
            case .__unknown(_):
                statusText = String(key: .BANK_ID_AUTH_TITLE_INITIATED)
            }

            statusLabel.styledTextSignal.value = StyledText(text: statusText, style: .rowTitle)
            
            
            containerStackView.systemLayoutSizeFitting(CGSize.zero)
            
            containerStackView.layoutIfNeeded()
        }
        
        func showFallbackQRCode(_ url: URL) {
            let data = url.absoluteString.data(using: String.Encoding.ascii)
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
            qrFilter.setValue(data, forKey: "inputMessage")
            guard let qrImage = qrFilter.outputImage else { return }
            
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQrImage = qrImage.transformed(by: transform)
            
            guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return }
            colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
            guard let outputInvertedImage = colorInvertFilter.outputImage else { return }
            
            let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputRadius0":100,
            "inputRadius1":100,
            "inputColor0":CIColor(red: 1, green: 1, blue: 1, alpha:1),
            "inputColor1":CIColor(red: 0, green: 0, blue: 0, alpha:0)
            ])?.outputImage
            
            guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha", parameters: [kCIInputImageKey: circle!]) else { return }
            maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
            guard let outputCIImage = maskToAlphaFilter.outputImage else { return }
            
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return }
            let processedImage = UIImage(cgImage: cgImage)
            
            imageView.image = processedImage
        }

        bag += client.perform(mutation: BankIdAuthMutation()).valueSignal.compactMap { result in result.data?.bankIdAuth.autoStartToken }.onValue { autoStartToken in
            let urlScheme = Bundle.main.urlScheme ?? ""
            guard let url = URL(string: "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid") else { return }

            if UIApplication.shared.canOpenURL(url) {
                hasBankIDInstalledSignal.value = true
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                hasBankIDInstalledSignal.value = false
                showFallbackQRCode(url)
            }
        }

        return (viewController, Future { completion in
            bag += closeButton.onTapSignal.onValue {
                completion(.failure(BankIdSignError.failed))
            }
            
            bag += statusSignal.withLatestFrom(view.windowSignal.atOnce().plain()).onValue({ authState, window in
                print(authState)
                
                if authState == .success {
                    bag += window?.present(LoggedIn(), animated: true)
                }
            })

            return bag
        })
    }
}
