//
//  DismissButton.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Flow
import Form
import Foundation

struct DismissButton {
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())
    let onTapSignal: Signal<Void>
    
    init() {
        self.onTapSignal = onTapReadWriteSignal.plain()
    }
}

extension DismissButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Disposable) {
        let bag = DisposeBag()
        let button = UIControl()
        
        bag += button.signal(for: .touchDown).map { 0.5 }.bindTo(
            animate: AnimationStyle.easeOut(duration: 0.25),
            button,
            \.alpha
        )
        
        let touchUpInside = button.signal(for: .touchUpInside)
        
        bag += touchUpInside.feedback(type: .impactLight)
        
        bag += touchUpInside.map { _ -> Void in
            ()
            }.bindTo(onTapReadWriteSignal)
        
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
