//
//  EmergencyActions.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct EmergencyActions {
    let presentingViewController: UIViewController
}

struct EmergencyAction: Reusable, SignalProvider {
    let title: String
    let description: String
    let buttonTitle: String
    private let onClickButtonCallbacker = Callbacker<Void>()

    var providedSignal: Signal<Void> {
        onClickButtonCallbacker.providedSignal
    }

    static func makeAndConfigure() -> (make: UIView, configure: (EmergencyAction) -> Disposable) {
        let view = UIStackView()
        view.axis = .vertical

        let cardContainer = UIView()
        cardContainer.backgroundColor = .brand(.secondaryBackground())
        cardContainer.layer.cornerRadius = 8

        view.addArrangedSubview(cardContainer)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .fill
        contentView.spacing = 5
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentView.isLayoutMarginsRelativeArrangement = true

        cardContainer.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let titleLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        contentView.addArrangedSubview(titleLabel)

        return (view, { action in
            let bag = DisposeBag()

            bag += cardContainer.applyShadow { _ in
                UIView.ShadowProperties(
                    opacity: 0.05,
                    offset: CGSize(width: 0, height: 16),
                    radius: 30,
                    color: .brand(.primaryShadowColor),
                    path: nil
                )
            }

            titleLabel.text = action.title

            let descriptionLabel = MultilineLabel(
                value: action.description,
                style: .brand(.body(color: .secondary))
            )
            bag += contentView.addArranged(descriptionLabel)

            let button = Button(
                title: action.buttonTitle,
                type: .standard(
                    backgroundColor: .brand(.primaryButtonBackgroundColor),
                    textColor: .brand(.primaryButtonTextColor)
                )
            )
            bag += contentView.addArranged(button.wrappedIn(UIStackView())) { stackView in
                stackView.alignment = .center
                stackView.axis = .vertical
                stackView.edgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
                stackView.isLayoutMarginsRelativeArrangement = true
            }

            bag += button.onTapSignal.onValue { _ in action.onClickButtonCallbacker.callAll() }

            return bag
        })
    }
}

extension EmergencyActions: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 5,
                left: 15,
                bottom: 5,
                right: 15
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .none,
            selectedBackground: .none,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, EmergencyAction>(style: style, holdIn: bag)
        tableKit.view.isScrollEnabled = false

        bag += tableKit.delegate.willDisplayCell.onValue { cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        }

        let callMeAction = EmergencyAction(
            title: L10n.emergencyCallMeTitle,
            description: L10n.emergencyCallMeDescription,
            buttonTitle: L10n.emergencyCallMeButton
        )

        bag += callMeAction.onValue {
            Home.openCallMeChatHandler(presentingViewController)
        }

        let emergencyAbroadAction = EmergencyAction(
            title: L10n.emergencyAbroadTitle,
            description: L10n.emergencyAbroadDescription,
            buttonTitle: L10n.emergencyAbroadButton
        )

        bag += emergencyAbroadAction.onValue {
            let phoneNumber = L10n.emergencyAbroadButtonActionPhoneNumber
            guard let phoneNumberUrl = URL(string: "tel:\(phoneNumber)") else { return }

            if UIApplication.shared.canOpenURL(phoneNumberUrl) {
                UIApplication.shared.open(phoneNumberUrl, options: [:], completionHandler: nil)
            } else {
                let nonPhoneAlert = Alert<Void>(
                    title: L10n.emergencyAbroadAlertNonPhoneTitle,
                    message: phoneNumber,
                    actions: [Alert<Void>.Action(title: L10n.emergencyAbroadAlertNonPhoneOkButton) {}]
                )

                self.presentingViewController.present(nonPhoneAlert)
            }
        }

        let unsureAction = EmergencyAction(
            title: L10n.emergencyUnsureTitle,
            description: L10n.emergencyUnsureDescription,
            buttonTitle: L10n.emergencyUnsureButton
        )

        bag += unsureAction.onValue {
            Home.openFreeTextChatHandler(presentingViewController)
        }

        let rows = [
            callMeAction,
            emergencyAbroadAction,
            unsureAction,
        ]

        tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })
        tableKit.view.backgroundColor = .brand(.primaryBackground())

        bag += tableKit.view.signal(for: \.contentSize).onValue { contentSize in
            tableKit.view.snp.updateConstraints { make in
                make.height.equalTo(
                    contentSize.height
                )
            }
        }

        return (tableKit.view, bag)
    }
}
