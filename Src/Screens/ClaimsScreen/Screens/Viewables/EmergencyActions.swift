//
//  EmergencyActions.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Flow
import Form
import Foundation
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
        return onClickButtonCallbacker.signal()
    }

    static func makeAndConfigure() -> (make: UIView, configure: (EmergencyAction) -> Disposable) {
        let view = UIStackView()
        view.axis = .vertical

        let cardContainer = UIView()
        cardContainer.backgroundColor = .secondaryBackground
        cardContainer.layer.cornerRadius = 8
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 16)
        cardContainer.layer.shadowRadius = 30
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.05

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

        let titleLabel = UILabel(value: "", style: .blockRowTitle)
        contentView.addArrangedSubview(titleLabel)

        return (view, { action in
            let bag = DisposeBag()

            titleLabel.text = action.title

            let descriptionLabel = MultilineLabel(value: action.description, style: .blockRowDescription)
            bag += contentView.addArranged(descriptionLabel)

            let button = Button(title: action.buttonTitle, type: .standard(backgroundColor: .primaryTintColor, textColor: .white))
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

var commonClaimEmergencyOpenFreeTextChat: (_ viewController: UIViewController) -> Void = { viewController in
    viewController.present(DraggableOverlay(presentable: FreeTextChat()))
}

var commonClaimEmergencyOpenCallMeChat: (_ viewController: UIViewController) -> Void = { viewController in
    viewController.present(DraggableOverlay(presentable: FreeTextChat()))
}

extension EmergencyActions: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 5,
                left: 20,
                bottom: 5,
                right: 20
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .invisible,
            selectedBackground: .invisible,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, EmergencyAction>(style: style, bag: bag)
        tableKit.view.isScrollEnabled = false

        bag += tableKit.delegate.willDisplayCell.onValue { cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        }

        let callMeAction = EmergencyAction(
            title: String(key: .EMERGENCY_CALL_ME_TITLE),
            description: String(key: .EMERGENCY_CALL_ME_DESCRIPTION),
            buttonTitle: String(key: .EMERGENCY_CALL_ME_BUTTON)
        )

        bag += callMeAction.onValue {
            commonClaimEmergencyOpenCallMeChat(self.presentingViewController)
        }

        let emergencyAbroadAction = EmergencyAction(
            title: String(key: .EMERGENCY_ABROAD_TITLE),
            description: String(key: .EMERGENCY_ABROAD_DESCRIPTION),
            buttonTitle: String(key: .EMERGENCY_ABROAD_BUTTON)
        )

        bag += emergencyAbroadAction.onValue {
            let phoneNumber = String(key: .EMERGENCY_ABROAD_BUTTON_ACTION_PHONE_NUMBER)
            guard let phoneNumberUrl = URL(string: "tel:\(phoneNumber)") else { return }

            if UIApplication.shared.canOpenURL(phoneNumberUrl) {
                UIApplication.shared.open(phoneNumberUrl, options: [:], completionHandler: nil)
            } else {
                let nonPhoneAlert = Alert<Void>(
                    title: String(key: .EMERGENCY_ABROAD_ALERT_NON_PHONE_TITLE),
                    message: phoneNumber,
                    actions: [Alert<Void>.Action(title: String(key: .EMERGENCY_ABROAD_ALERT_NON_PHONE_OK_BUTTON)) {}]
                )

                self.presentingViewController.present(nonPhoneAlert)
            }
        }

        let unsureAction = EmergencyAction(
            title: String(key: .EMERGENCY_UNSURE_TITLE),
            description: String(key: .EMERGENCY_UNSURE_DESCRIPTION),
            buttonTitle: String(key: .EMERGENCY_UNSURE_BUTTON)
        )

        bag += unsureAction.onValue {
            commonClaimEmergencyOpenFreeTextChat(self.presentingViewController)
        }

        let rows = [
            callMeAction,
            emergencyAbroadAction,
            unsureAction,
        ]

        tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })
        tableKit.view.backgroundColor = .primaryBackground

        return (tableKit.view, bag)
    }
}
