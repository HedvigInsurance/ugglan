//
//  CoinsuredComingSoonText.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-05.
//

import Flow
import Form
import Foundation
import UIKit

struct CoinsuredComingSoonText {}

extension CoinsuredComingSoonText: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let view = UIStackView()
        let bag = DisposeBag()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.spacing = 15

        let titleContainer = UIView()

        let title = UILabel(style: .blockRowTitle)
        title.text = String(.MY_COINSURED_COMING_SOON_TITLE)

        bag += title.didLayoutSignal.onValue {
            title.setContentHuggingPriority(
                UILayoutPriority.defaultLow,
                for: .horizontal
            )
            title.snp.remakeConstraints { make in
                make.width.equalTo(450).priority(.high)
                make.width.lessThanOrEqualToSuperview()
                    .inset(25).priority(.required)
                make.height.equalTo(title.intrinsicContentSize.height)
                make.center.equalToSuperview()
            }

            titleContainer.snp.remakeConstraints { make in
                make.height.equalTo(title.intrinsicContentSize.height)
            }
        }

        titleContainer.addSubview(title)
        view.addArrangedSubview(titleContainer)

        let bodyContainer = UIView()

        let body = MultilineLabel(
            styledText: StyledText(
                text: String(.MY_COINSURED_COMING_SOON_BODY),
                style: .body
            )
        )

        bag += bodyContainer.add(body) { label in
            bag += body.intrinsicContentSizeSignal.onValue { contentSize in
                label.setContentHuggingPriority(
                    UILayoutPriority.defaultLow,
                    for: .horizontal
                )
                label.snp.remakeConstraints { make in
                    make.width.equalTo(450).priority(.high)
                    make.width.lessThanOrEqualToSuperview()
                        .inset(25).priority(.required)
                    
                    make.height.equalTo(contentSize.height)
                    make.center.equalToSuperview()
                }

                bodyContainer.snp.remakeConstraints { make in
                    make.height.equalTo(contentSize.height)
                }
            }
        }

        view.addArrangedSubview(bodyContainer)

        return (view, bag)
    }
}
