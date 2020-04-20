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
    @Inject var client: ApolloClient
    @Inject var remoteConfigContainer: RemoteConfigContainer
    let codeSignal: Signal<String>
    let presentingViewController: UIViewController

    init(
        codeSignal: Signal<String>,
        presentingViewController: UIViewController
    ) {
        self.codeSignal = codeSignal
        self.presentingViewController = presentingViewController
    }
}

extension ReferralsCode: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIControl()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 6

        let touchUpInsideSignal = view.signal(for: .touchUpInside)
        bag += touchUpInsideSignal.feedback(type: .success)

        bag += touchUpInsideSignal.withLatestFrom(codeSignal).onValueDisposePrevious { _, code in
            let register = PushNotificationsRegister(
                title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE),
                message: String(key: .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE)
            )

            return self.presentingViewController.present(register).onValue { _ in
                UIPasteboard.general.value = code
                UIApplication.shared.appDelegate.displayToast(Toast(
                    symbol: nil,
                    body: String(key: .COPIED)
                )).onValue { _ in }
            }.disposable
        }

        let codeContainer = UIStackView()
        codeContainer.isUserInteractionEnabled = false
        codeContainer.spacing = 10
        codeContainer.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 12)
        codeContainer.isLayoutMarginsRelativeArrangement = true

        let codeTextStyle = TextStyle(
            font: HedvigFonts.favoritStdBook!,
            color: UIColor.primaryTintColor
        ).centerAligned.lineHeight(2.4).resized(to: 16)

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
