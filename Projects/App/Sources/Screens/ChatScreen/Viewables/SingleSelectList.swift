//
//  SingleSelectList.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-01.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct SingleSelectList: Hashable, Equatable {
    let id = UUID()
    let options: [SingleSelectOption]
    let chatState: ChatState
    @Inject var client: ApolloClient
    let navigateCallbacker: Callbacker<NavigationEvent>

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(
        options: [SingleSelectOption],
        chatState: ChatState,
        navigateCallbacker: Callbacker<NavigationEvent>
    ) {
        self.options = options
        self.chatState = chatState
        self.navigateCallbacker = navigateCallbacker
    }
}

extension SingleSelectList: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (SingleSelectList) -> Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .trailing
        containerView.distribution = .equalCentering

        let spacingContainer = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .trailing
        spacingContainer.insetsLayoutMarginsFromSafeArea = false
        spacingContainer.isLayoutMarginsRelativeArrangement = true

        containerView.addArrangedSubview(spacingContainer)

        return (containerView, { singleSelectList in
            spacingContainer.addArranged(singleSelectList)
        })
    }
}

extension SingleSelectList: Viewable {
    func materialize(events _: ViewableEvents) -> (UIScrollView, Disposable) {
        let bag = DisposeBag()

        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true

        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .trailing
        view.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 0)
        view.isLayoutMarginsRelativeArrangement = true

        scrollView.embedView(view, scrollAxis: .horizontal)

        view.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(scrollView.snp.width)
        }

        let contentContainerView = UIStackView()
        contentContainerView.axis = .horizontal
        contentContainerView.alignment = .center
        contentContainerView.spacing = 15

        view.addArrangedSubview(contentContainerView)

        bag += options.enumerated().map { arg in
            let (index, option) = arg
            let innerBag = DisposeBag()
            let button = Button(
                title: option.text,
                type: .standardSmall(backgroundColor: .brand(.secondaryBackground()), textColor: .brand(.primaryButtonTextColor))
            )

            innerBag += button.onTapSignal.onValue { _ in
                func removeViews() {
                    view.arrangedSubviews.forEach { subView in
                        innerBag += Signal(after: 0).animated(style: SpringAnimationStyle.mediumBounce(), animations: { _ in
                            subView.transform = CGAffineTransform(translationX: subView.frame.width, y: 0)
                            subView.alpha = 0
                        })
                    }
                }
                switch option.type {
                case let .link(view):
                    if view == .offer {
                        self.navigateCallbacker.callAll(with: .offer)
                    } else if view == .dashboard {
                        self.navigateCallbacker.callAll(with: .dashboard)
                    }
                    removeViews()
                case .selection:
                    self.chatState.sendSingleSelectResponse(selectedValue: option.value)
                    removeViews()
                case .login:
                    self.navigateCallbacker.callAll(with: .login)
                }
            }

            let buttonWrapper = UIStackView()
            buttonWrapper.axis = .vertical
            buttonWrapper.alignment = .center

            innerBag += contentContainerView.addArranged(button.wrappedIn(buttonWrapper))

            if let buttonView = buttonWrapper.subviews.first {
                innerBag += buttonView.hasWindowSignal.atOnce().atValue { _ in
                    buttonView.alpha = 0
                    buttonView.transform = CGAffineTransform(translationX: buttonView.frame.width + 70, y: 0)
                }.delay(by: 0.2).animated(style: SpringAnimationStyle.mediumBounce(delay: Double(index) * 0.1), animations: { _ in
                    buttonView.transform = .identity
                    buttonView.alpha = 1
                })
            }

            return innerBag
        }

        return (scrollView, bag)
    }
}
