//
//  CoronaSection.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2020-03-14.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import SafariServices
import UIKit

struct ImportantMessagesSection {
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient
}

extension ImportantMessagesSection {
    struct Message: Viewable {
        let presentingViewController: UIViewController
        let title: String
        let message: String
        let buttonText: String
        let link: String

        func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
            let bag = DisposeBag()

            let containerView = UIVisualEffectView()
            if #available(iOS 13.0, *) {
                containerView.effect = UIBlurEffect(style: .systemChromeMaterial)
            } else {
                containerView.effect = UIBlurEffect(style: .prominent)
            }
            containerView.layer.cornerRadius = 6
            containerView.layer.masksToBounds = true

            let containerStackView = UIStackView()
            containerStackView.axis = .vertical
            containerStackView.spacing = 12
            containerStackView.alignment = .fill
            containerStackView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
            containerStackView.isLayoutMarginsRelativeArrangement = true

            containerView.contentView.addSubview(containerStackView)

            containerStackView.snp.makeConstraints { make in
                make.height.width.centerX.centerY.equalToSuperview()
            }

            let titleLabel = MultilineLabel(
                value: title,
                style: TextStyle.brand(.title3(color: .primary)).centerAligned
            )
            bag += containerStackView.addArranged(titleLabel)

            let infoLabel = MarkdownText(
                value: message,
                style: TextStyle.brand(.body(color: .primary)).centerAligned
            )
            bag += containerStackView.addArranged(infoLabel)

            let buttonContainer = UIView()
            let button = Button(
                title: buttonText,
                type: .outline(borderColor: .brand(.primaryText()), textColor: .brand(.primaryText()))
            )
            bag += buttonContainer.add(button) { buttonView in
                buttonView.snp.makeConstraints { make in
                    make.height.centerY.centerX.equalToSuperview()
                }
            }

            bag += button.onTapSignal.onValue { _ in
                if let url = URL(string: self.link) {
                    self.presentingViewController.present(
                        SFSafariViewController(url: url),
                        animated: true,
                        completion: nil
                    )
                }
            }

            containerStackView.addArrangedSubview(buttonContainer)

            return (containerView, bag)
        }
    }
}

extension ImportantMessagesSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let wrapper = UIStackView()
        wrapper.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        wrapper.isLayoutMarginsRelativeArrangement = true
        wrapper.isHidden = true

        bag += client.fetch(query: GraphQL.ImportantMessagesQuery(languageCode: Localization.Locale.currentLocale.code)).valueSignal.compactMap {
            $0.data?.importantMessages.compactMap { $0 }
        }.onValueDisposePrevious { messages in
            let innerBag = DisposeBag()

            innerBag += messages.map { message in
                wrapper.addArranged(Message(
                    presentingViewController: self.presentingViewController,
                    title: message.title ?? "",
                    message: message.message ?? "",
                    buttonText: message.button ?? "",
                    link: message.link ?? ""
                ))
            }

            innerBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                wrapper.animationSafeIsHidden = false
            }

            return innerBag
        }

        return (wrapper, bag)
    }
}
