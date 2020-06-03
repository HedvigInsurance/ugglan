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

            let containerView = UIView()
            containerView.backgroundColor = .secondaryBackground
            containerView.layer.cornerRadius = 6

            let containerStackView = UIStackView()
            containerStackView.axis = .vertical
            containerStackView.spacing = 12
            containerStackView.alignment = .fill
            containerStackView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
            containerStackView.isLayoutMarginsRelativeArrangement = true

            containerView.addSubview(containerStackView)

            containerStackView.snp.makeConstraints { make in
                make.height.width.centerX.centerY.equalToSuperview()
            }

            let titleLabel = MultilineLabel(value: title, style: TextStyle.rowTitleBold.centerAligned)
            bag += containerStackView.addArranged(titleLabel)

            let infoLabel = MarkdownText(textSignal: .static(message), style: TextStyle.body.centerAligned)
            bag += containerStackView.addArranged(infoLabel)

            let buttonContainer = UIView()
            let button = Button(
                title: buttonText,
                type: .outline(borderColor: .primaryText, textColor: .primaryText)
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

        bag += client.fetch(query: ImportantMessagesQuery(languageCode: Localization.Locale.currentLocale.code)).valueSignal.compactMap {
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
