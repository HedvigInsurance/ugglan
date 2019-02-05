//
//  MyCoinsured.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-05.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct MyCoinsured {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension MyCoinsured: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let form = FormView()

        let circleContainerView = UIView()

        let circleLabel = CircleLabelWithSubLabel(
            labelText: DynamicString(""),
            subLabelText: DynamicString(String(.MY_COINSURED_SCREEN_CIRCLE_SUBLABEL)),
            appearance: .purple
        )
        bag += circleContainerView.add(circleLabel)

        circleContainerView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }

        form.append(circleContainerView)

        bag += client.watch(query: MyCoinsuredQuery()).compactMap {
            $0.data?.insurance.personsInHousehold
        }.map { String($0) }.bindTo(circleLabel.labelText)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
