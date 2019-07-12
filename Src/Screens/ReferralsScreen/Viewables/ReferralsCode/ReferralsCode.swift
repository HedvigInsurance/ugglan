//
//  ReferralsCode.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Apollo
import Flow
import Form
import Presentation
import Foundation
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
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.offLightGray.cgColor
        view.layer.borderWidth = 1

        bag += view.didLayoutSignal.onValue { _ in
            view.layer.cornerRadius = view.frame.height / 2
        }
        
        let tapGesture = UITapGestureRecognizer()
        bag += view.install(tapGesture)
        bag += tapGesture.signal(forState: .ended).withLatestFrom(codeSignal).atValue { _, code in
            let alert = Alert<Bool>(
                title: nil,
                message: nil,
                tintColor: nil,
                actions: [
                    Alert.Action(
                        title: String(key: .REFERRAL_ERROR_REPLACECODE_BTN_CANCEL),
                        style: .cancel
                    ) { false },
                    Alert.Action(
                        title: String(key: .REFERRALS_CODE_SHEET_COPY),
                        style: .default
                    ) { true },
                ]
            )
            
            bag += self.presentingViewController.present(alert, style: .sheet(from: view, rect: view.bounds)).onValue { shouldCopy in
                if shouldCopy {
                    UIPasteboard.general.value = "\(self.remoteConfigContainer.referralsWebLandingPrefix)\(code)"
                    bag += Signal(after: 0).feedback(type: .success)
                    PushNotificationsRegistrer.ask(title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE), message: String(key: .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE), viewController: self.presentingViewController)
                }
            }
        }.feedback(type: .impactMedium)
        
        bag += view.copySignal.withLatestFrom(codeSignal).atValue { _, code in
            UIPasteboard.general.value = "\(self.remoteConfigContainer.referralsWebLandingPrefix)\(code)"
            PushNotificationsRegistrer.ask(title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE), message: String(key: .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE), viewController: self.presentingViewController)
        }.feedback(type: .success)

        let codeContainer = UIStackView()
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
        let codeLabel = MultilineLabel(value: "", style: codeTextStyle)
        bag += codeSignal.withLatestFrom(remoteConfigContainer.fetched.atOnce().filter { $0 != false }).map { code, _ in
            let formattedLinkPrefix = self.remoteConfigContainer.referralsWebLandingPrefix.replacingOccurrences(of: "(^\\w+:|^)\\/\\/", with: "", options: .regularExpression, range: nil)
            return StyledText(text: "\(formattedLinkPrefix)\(code)", style: codeTextStyle)
        }.bindTo(codeLabel.styledTextSignal)
        
        bag += codeLabelWrapper.add(codeLabel) { codeLabelView in
            codeLabelView.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
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
