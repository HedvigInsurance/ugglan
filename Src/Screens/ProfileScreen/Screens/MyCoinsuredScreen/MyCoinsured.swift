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
#if canImport(Lottie)
    import Lottie
#endif
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
        viewController.title = String(.MY_COINSURED_TITLE)

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
        }.map { String($0 - 1) }.bindTo(circleLabel.labelText)

        bag += form.append(Spacing(height: 20))

        let lottieContainerView = UIView()

        let lottieView = LOTAnimationView(name: Asset.buildingAnimation.name)

        lottieContainerView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        lottieView.play()
        lottieView.loopAnimation = true
        lottieView.contentMode = .scaleAspectFit

        lottieContainerView.addSubview(lottieView)

        lottieView.snp.makeConstraints { make in
            make.width.equalTo(189)
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        form.append(lottieContainerView)

        bag += form.append(Spacing(height: 20))

        let coinsuredComingSoonText = CoinsuredComingSoonText()
        bag += form.append(coinsuredComingSoonText)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
