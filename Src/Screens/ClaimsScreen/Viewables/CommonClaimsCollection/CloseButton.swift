//
//  CloseButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-18.
//

import Foundation
import Form
import Flow

struct CloseButton {}

extension CloseButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIControl, Disposable) {
        let bag = DisposeBag()
        let button = UIControl()
        
        bag += button.signal(for: .touchDown).map { 0.5 }.bindTo(
            animate: AnimationStyle.easeOut(duration: 0.25),
            button,
            \.alpha
        )
        
        bag += merge(
            button.signal(for: .touchUpInside),
            button.signal(for: .touchUpOutside),
            button.signal(for: .touchCancel)
        ).map { 1 }.bindTo(
                animate: AnimationStyle.easeOut(duration: 0.25),
                button,
                \.alpha
        )
        
        let icon = Icon(icon: Asset.close, iconWidth: 17)
        button.addSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        return (button, bag)
    }
}
