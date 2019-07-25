//
//  ReferralsCode.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct ReferralsCode {
    let client: ApolloClient
    let codeSignal: Signal<String>
    let presentingViewController: UIViewController
    let remoteConfigContainer: RemoteConfigContainer

    init(codeSignal: Signal<String>, client: ApolloClient = ApolloContainer.shared.client, presentingViewController: UIViewController, remoteConfigContainer: RemoteConfigContainer = RemoteConfigContainer.shared) {
        self.client = client
        self.codeSignal = codeSignal
        self.presentingViewController = presentingViewController
        self.remoteConfigContainer = remoteConfigContainer
    }
}

extension ReferralsCode: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIControl()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.offLightGray.cgColor
        view.layer.borderWidth = 1

        bag += view.didLayoutSignal.onValue { _ in
            view.layer.cornerRadius = view.frame.height / 2
        }

        let touchUpInsideSignal = view.signal(for: .touchUpInside)
        bag += touchUpInsideSignal.feedback(type: .success)

        bag += touchUpInsideSignal.withLatestFrom(codeSignal).onValueDisposePrevious { _, code in
            let register = PushNotificationsRegister(
                title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE),
                message: String(key: .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE)
            )

            return self.presentingViewController.present(register).onValue { _ in
                UIPasteboard.general.value = code
                UIApplication.shared.appDelegate.createToast(
                    symbol: .character("🎉"),
                    body: String(key: .COPIED)
                )
            }.disposable
        }

        let codeContainer = UIStackView()
        codeContainer.isUserInteractionEnabled = false
        codeContainer.spacing = 10
        codeContainer.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 12)
        codeContainer.isLayoutMarginsRelativeArrangement = true

        let codeTextStyle = TextStyle(
            font: HedvigFonts.circularStdBold!,
            color: UIColor.purple
        ).centerAligned.lineHeight(2.4).resized(to: 16).restyled { (style: inout TextStyle) in
            style.highlightedColor = .darkPurple
        }

        let codeLabelWrapper = UIView()
        let codeLabel = UILabel(value: "", style: codeTextStyle)
        bag += codeSignal.map { code in
            StyledText(text: code, style: codeTextStyle)
        }.bindTo(codeLabel, \.styledText)

        codeLabelWrapper.addSubview(codeLabel)
        codeLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        codeContainer.addArrangedSubview(codeLabelWrapper)

        let copyIconWrapper = UIView()
        copyIconWrapper.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        let copyIcon = UIImageView()
        copyIcon.image = Asset.copy.image
        copyIconWrapper.addSubview(copyIcon)
        copyIcon.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerX.centerY.equalToSuperview()
        }

        codeContainer.addArrangedSubview(copyIconWrapper)

        view.addSubview(codeContainer)

        codeContainer.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        return (view, bag)
    }
}
