//
//  DraggableViewHeader.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-28.
//

import Flow
import Foundation
import hCore
import UIKit

struct DraggableOverlayHeader {
    let title: String
}

extension DraggableOverlayHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()

        let bag = DisposeBag()

        let titleLabel = UILabel()
        titleLabel.style = .draggableOverlayTitle
        titleLabel.textAlignment = .left

        bag += titleLabel.setDynamicText(DynamicString(title))

        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)

        bag += titleLabel.didLayoutSignal.onValue { _ in
            titleLabel.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(24)
                make.height.equalTo(24)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(0)
            }
        }

        view.addSubview(titleContainer)

        titleContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }

        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalTo(56)
        }

        return (view, bag)
    }
}
