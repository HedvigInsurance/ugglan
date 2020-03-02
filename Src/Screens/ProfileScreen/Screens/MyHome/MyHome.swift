//
//  MyResidence.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-12.
//

import Apollo
import Flow
import Form
import Presentation

struct MyHome {
    @Inject var client: ApolloClient

    init(
    ) {}
}

extension MyHome: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .MY_HOME_TITLE)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)

        let form = FormView()
        bag += viewController.install(form)
        
        form.append(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(form.safeAreaLayoutGuide)
        }

        let addressCircle = AddressCircle()
        bag += stackView.addArranged(addressCircle)

        let rowTitle = UILabel(value: String(key: .MY_HOME_SECTION_TITLE), style: .rowTitle)

        bag += stackView.addArranged(InsuranceSummarySection(headerView: rowTitle))

        bag += stackView.addArranged(Spacing(height: 20))

        let buttonSection = ButtonSection(
            text: String(key: .MY_HOME_CHANGE_INFO_BUTTON),
            style: .normal
        )
        bag += stackView.addArranged(buttonSection)

        bag += buttonSection.onSelect.onValue {
            let alert = Alert<Bool>(
                title: String(key: .MY_HOME_CHANGE_ALERT_TITLE),
                message: String(key: .MY_HOME_CHANGE_ALERT_MESSAGE),
                actions: [
                    Alert.Action(title: String(key: .MY_HOME_CHANGE_ALERT_ACTION_CANCEL)) { false },
                    Alert.Action(title: String(key: .MY_HOME_CHANGE_ALERT_ACTION_CONFIRM)) { true },
                ]
            )

            viewController.present(alert).onValue { shouldContinue in
                if shouldContinue {
                    viewController.present(
                        FreeTextChat().withCloseButton,
                        style: .modally(
                            presentationStyle: .pageSheet,
                            transitionStyle: nil,
                            capturesStatusBarAppearance: true
                        )
                    )
                }
            }
        }

        return (viewController, bag)
    }
}
