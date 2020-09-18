//
//  ContentIconPagerItem.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

public struct ContentIconPagerItem {
    let title: String?
    let paragraph: String
    let icon: GraphQL.IconFragment

    public var pagerItem: PagerItem {
        PagerItem(id: .init(), content: AnyPresentable(self))
    }

    public init(
        title: String?,
        paragraph: String,
        icon: GraphQL.IconFragment
    ) {
        self.title = title
        self.paragraph = paragraph
        self.icon = icon
    }
}

extension ContentIconPagerItem: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        let containerView = UIStackView()
        containerView.alpha = 1
        containerView.alignment = .center
        containerView.axis = .horizontal
        containerView.distribution = .fill
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let loadingIndicator = LoadingIndicator(showAfter: 0, color: .black)
        let loadingIndicatorBag = DisposeBag()
        loadingIndicatorBag += containerView.addArranged(loadingIndicator)
        bag += loadingIndicatorBag

        let innerContainerView = UIStackView()
        innerContainerView.alpha = 0
        innerContainerView.alignment = .center
        innerContainerView.axis = .vertical
        innerContainerView.spacing = 8
        innerContainerView.isLayoutMarginsRelativeArrangement = true

        let remoteVectorIcon = RemoteVectorIcon(icon, threaded: true)
        containerView.addArrangedSubview(innerContainerView)

        innerContainerView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
        }

        bag += remoteVectorIcon.finishedLoadingSignal.onValue { _ in
            bag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.25), animations: {
                innerContainerView.alpha = 1
                loadingIndicatorBag.dispose()
            })
        }

        bag += innerContainerView.addArranged(remoteVectorIcon) { iconView in
            iconView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(180)
            }
        }

        let spacing = Spacing(height: 30)
        bag += innerContainerView.addArranged(spacing)

        if let title = title {
            let titleLabel = MultilineLabel(styledText: StyledText(
                text: title,
                style: TextStyle.brand(.title1(color: .primary)).centerAligned
            ))

            bag += innerContainerView.addArranged(titleLabel) { titleLabelView in
                titleLabelView.snp.makeConstraints { make in
                    make.width.equalToSuperview()
                    make.centerX.equalToSuperview()
                    make.height.equalTo(100)
                }
            }
        }

        let bodyLabel = MultilineLabel(styledText: StyledText(
            text: paragraph,
            style: TextStyle.brand(.body(color: title != nil ? .secondary : .primary)).centerAligned
        ))

        bag += innerContainerView.addArranged(bodyLabel) { bodyLabelView in
            bodyLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(100)
            }
        }

        viewController.view = containerView

        bag += viewController.view.didLayoutSignal.onValue { _ in
            containerView.snp.makeConstraints { make in
                make.height.centerX.centerY.equalToSuperview()
                make.width.equalToSuperview().inset(20)
            }
        }

        return (viewController, bag)
    }
}
