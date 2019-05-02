//
//  EmergencyActions.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Flow
import Form
import Foundation
import UIKit

struct EmergencyActions {}

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
        cardContainer.backgroundColor = .white
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
        contentView.layoutMargins = UIEdgeInsets(top: 25, left: 15, bottom: 25, right: 15)
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

            let button = Button(title: action.buttonTitle, type: .standard(backgroundColor: .purple, textColor: .white))
            bag += contentView.addArranged(button.wrappedIn(UIStackView())) { stackView in
                stackView.alignment = .center
                stackView.axis = .vertical
                stackView.edgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
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
                left: 20,
                bottom: 5,
                right: 20
            ),
            itemSpacing: 0,
            minRowHeight: 1,
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
            title: "Prata med någon",
            description: "Befinner du dig i en krisstuation kan vi ringa upp dig. Tänk på att meddela SOS Alarm först vid nödsituationer!",
            buttonTitle: "Ring mig"
        )

        bag += callMeAction.onValue {
            print("call me")
        }

        let emergencyAbroadAction = EmergencyAction(
            title: "Akut sjuk utomlands",
            description: "Är du akut sjuk eller skadad utomlands och behöver vård? Det första du behöver göra är att kontakta Hedvig Global Assistance.",
            buttonTitle: "Ring Hedvig Global Assistance"
        )

        bag += emergencyAbroadAction.onValue {
            print("call me")
        }

        let unsureAction = EmergencyAction(
            title: "Osäker?",
            description: "Osäker på om ditt tillstånd räknas som akut? Kontakta Hedvig först!",
            buttonTitle: "Skriv till oss"
        )

        bag += unsureAction.onValue {
            print("open chat")
        }

        let rows = [
            callMeAction,
            emergencyAbroadAction,
            unsureAction,
        ]

        tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })
        tableKit.view.backgroundColor = .offWhite

        return (tableKit.view, bag)
    }
}
