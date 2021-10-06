import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct EmergencyActions { let presentingViewController: UIViewController }

struct EmergencyAction: Reusable, SignalProvider {
    let title: String
    let description: String
    let buttonTitle: String
    private let onClickButtonCallbacker = Callbacker<Void>()

    var providedSignal: Signal<Void> { onClickButtonCallbacker.providedSignal }

    static func makeAndConfigure() -> (make: UIView, configure: (EmergencyAction) -> Disposable) {
        let view = UIStackView()
        view.axis = .vertical

        let cardContainer = UIView()
        cardContainer.backgroundColor = .brand(.primaryBackground())
        cardContainer.layer.cornerRadius = 8

        view.addArrangedSubview(cardContainer)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .fill
        contentView.spacing = 5
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentView.isLayoutMarginsRelativeArrangement = true

        cardContainer.addSubview(contentView)

        contentView.snp.makeConstraints { make in make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let titleLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        contentView.addArrangedSubview(titleLabel)

        contentView.setCustomSpacing(8, after: titleLabel)

        return (
            view,
            { action in let bag = DisposeBag()

                titleLabel.text = action.title

                let descriptionLabel = MultilineLabel(
                    value: action.description,
                    style: .brand(.body(color: .secondary))
                )
                bag += contentView.addArranged(descriptionLabel)

                bag += contentView.addArranged(Spacing(height: 24))

                let button = Button(
                    title: action.buttonTitle,
                    type: .standard(
                        backgroundColor: .brand(.secondaryButtonBackgroundColor),
                        textColor: .brand(.secondaryButtonTextColor)
                    )
                )
                bag += contentView.addArranged(button)

                bag += button.onTapSignal.onValue { _ in action.onClickButtonCallbacker.callAll() }

                return bag
            }
        )
    }
}

extension EmergencyActions: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let sectionStyle = SectionStyle(
            insets: .zero,
            rowInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .none,
            selectedBackground: .none,
            shadow: .none,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in sectionStyle }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, EmergencyAction>(style: style, holdIn: bag)
        tableKit.view.isScrollEnabled = false

        bag += tableKit.delegate.willDisplayCell.onValue { cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
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
                    actions: [
                        Alert<Void>.Action(title: L10n.emergencyAbroadAlertNonPhoneOkButton) {}
                    ]
                )

                self.presentingViewController.present(nonPhoneAlert)
            }
        }

        let rows = [emergencyAbroadAction]

        tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })

        bag += tableKit.view.signal(for: \.contentSize)
            .onValue { contentSize in
                tableKit.view.snp.updateConstraints { make in make.height.equalTo(contentSize.height) }
            }

        return (tableKit.view, bag)
    }
}
