//
//  EmbarkSelectActionOption.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import UIKit
import Form

struct EmbarkSelectActionOption {
    let data: EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum.Option
}

extension EmbarkSelectActionOption: Viewable {
    func materialize(events: ViewableEvents) -> (UIControl, Signal<Void>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.backgroundColor = .white
        control.layer.cornerRadius = 10
        
        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        control.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        bag += stackView.addArranged(MultilineLabel(value: data.link.fragments.embarkLinkFragment.label, style: TextStyle.bodyBold.aligned(to: .center)))
                
        return (control, Signal { callback in
            bag += control.signal(for: .touchUpInside).onValue(callback)
            return bag
        })
    }
}
