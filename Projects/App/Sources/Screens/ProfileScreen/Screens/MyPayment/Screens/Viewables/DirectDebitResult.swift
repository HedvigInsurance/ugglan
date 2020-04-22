//
//  DirectDebitResult.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-25.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

enum DirectDebitResultType {
    case success(setupType: PaymentSetup.SetupType), failure(setupType: PaymentSetup.SetupType)

    var icon: ImageAsset {
        switch self {
        case .success:
            return Asset.circularCheckmark
        case .failure:
            return Asset.pinkCircularExclamationPoint
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    var headingText: String {
        switch self {
        case let .success(setupType):
            switch setupType {
            case .postOnboarding:
                return String(key: .ONBOARDING_CONNECT_DD_SUCCESS_HEADLINE)
            default:
                return String(key: .DIRECT_DEBIT_SUCCESS_HEADING)
            }
        case let .failure(setupType):
            switch setupType {
            case .postOnboarding:
                return String(key: .ONBOARDING_CONNECT_DD_FAILURE_HEADLINE)
            default:
                return String(key: .DIRECT_DEBIT_FAIL_HEADING)
            }
        }
    }

    var messageText: String {
        switch self {
        case let .success(setupType):
            switch setupType {
            case .postOnboarding:
                return String(key: .ONBOARDING_CONNECT_DD_SUCCESS_BODY)
            default:
                return String(key: .DIRECT_DEBIT_SUCCESS_MESSAGE)
            }
        case let .failure(setupType):
            switch setupType {
            case .postOnboarding:
                return String(key: .ONBOARDING_CONNECT_DD_FAILURE_BODY)
            default:
                return String(key: .DIRECT_DEBIT_FAIL_MESSAGE)
            }
        }
    }

    var mainButtonText: String {
        switch self {
        case let .success(setupType):
            switch setupType {
            case .postOnboarding:
                return String(key: .ONBOARDING_CONNECT_DD_SUCCESS_CTA)
            default:
                return String(key: .DIRECT_DEBIT_SUCCESS_BUTTON)
            }
        case .failure:
            return String(key: .ONBOARDING_CONNECT_DD_FAILURE_CTA_RETRY)
        }
    }
}

struct DirectDebitResult {
    enum ResultError: Error {
        case retry
    }

    let type: DirectDebitResultType
}

extension DirectDebitResult: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Future<Void>) {
        let containerView = UIView()
        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        containerView.alpha = 0

        let stackView = CenterAllStackView()
        stackView.axis = .vertical
        stackView.spacing = 15

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.edges.equalToSuperview()
        }

        let bag = DisposeBag()

        let icon = Icon(frame: .zero, icon: type.icon, iconWidth: 40)
        stackView.addArrangedSubview(icon)

        let heading = MultilineLabel(
            styledText: StyledText(
                text: type.headingText,
                style: .centeredHeadingOne
            )
        )

        bag += stackView.addArranged(heading) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(containerView.snp.width).inset(20)
            }
        }

        let body = MultilineLabel(
            styledText: StyledText(
                text: type.messageText,
                style: .centeredBody
            )
        )

        bag += stackView.addArranged(body) { view in
            view.snp.makeConstraints { make in
                make.width.lessThanOrEqualTo(containerView.snp.width).inset(20)
            }
        }

        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .vertical
        buttonsContainer.alignment = .center
        buttonsContainer.spacing = 10
        buttonsContainer.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        buttonsContainer.isLayoutMarginsRelativeArrangement = true

        stackView.addArrangedSubview(buttonsContainer)

        bag += events.wasAdded.delay(by: 0.5).animated(style: SpringAnimationStyle.heavyBounce()) {
            containerView.alpha = 1
            containerView.transform = CGAffineTransform.identity
        }

        bag += events.removeAfter.set { _ in
            1
        }

        return (containerView, Future { completion in
            if self.type.isSuccess {
                let continueButton = Button(
                    title: self.type.mainButtonText,
                    type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
                )

                bag += continueButton.onTapSignal.onValue { _ in
                    completion(.success)
                }

                bag += buttonsContainer.addArranged(continueButton.wrappedIn(UIStackView())) { stackView in
                    stackView.axis = .vertical
                    stackView.alignment = .center
                }
            } else {
                let retryButton = Button(
                    title: self.type.mainButtonText,
                    type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
                )

                bag += retryButton.onTapSignal.onValue { _ in
                    bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        containerView.alpha = 0
                        buttonsContainer.alpha = 0
                    }

                    completion(.failure(DirectDebitResult.ResultError.retry))
                }

                bag += buttonsContainer.addArranged(retryButton.wrappedIn(UIStackView())) { stackView in
                    stackView.axis = .vertical
                    stackView.alignment = .center
                }

                let skipButton = Button(
                    title: String(key: .ONBOARDING_CONNECT_DD_FAILURE_CTA_LATER),
                    type: .transparent(textColor: .pink)
                )

                bag += skipButton.onTapSignal.onValue { _ in
                    completion(.success)
                }

                bag += buttonsContainer.addArranged(skipButton.wrappedIn(UIStackView())) { stackView in
                    stackView.axis = .vertical
                    stackView.alignment = .center
                }
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
