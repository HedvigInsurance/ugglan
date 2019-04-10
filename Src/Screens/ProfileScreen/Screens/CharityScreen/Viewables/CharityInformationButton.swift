//
//  CharityInformationButton.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-04-04.
//

import Flow
import Foundation
import UIKit
import SnapKit

struct CharityInformationButton {
    let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
}

extension CharityInformationButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        
        let bag = DisposeBag()
        
        let button = Button(
            title: String(key: .PROFILE_MY_CHARITY_INFO_BUTTON),
            type: .iconTransparent(textColor: .purple, icon: Asset.infoPurple)
        )
        
        bag += view.add(button)
        
        bag += button.onTapSignal.onValue {_ in
            self.presentingViewController.present(
                DraggableOverlay(
                    presentable: CharityInformation(),
                    presentationOptions: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .prefersNavigationBarHidden(true)],
                    heightPercentage: 0.55
                )
            )
        }
        
        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(button.type.height())
        }
        
        return (view, bag)
    }
}
