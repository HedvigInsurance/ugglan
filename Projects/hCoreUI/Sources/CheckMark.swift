//
//  CheckMark.swift
//  hCoreUI
//
//  Created by Tarik Stafford on 2021-01-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import UIKit
import Flow
import hCore

public struct CheckMark {
    @ReadWriteState public var isSelected = false
    
    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    public init(isSelectedSignal: ReadWriteSignal<Bool>) {
        self._isSelected = .init(wrappedValue: isSelectedSignal)
    }
}

extension CheckMark: Viewable {
    
    public func materialize(events: ViewableEvents) -> (UIControl, Disposable) {
        let bag = DisposeBag()
        
        let control = UIControl()
        control.layer.cornerRadius = 2
        control.layer.borderWidth = .hairlineWidth
        
        let imageView = UIImageView()
        imageView.image = hCoreUIAssets.checkmark.image
        imageView.contentMode = .scaleAspectFit
        
        control.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview().inset(5)
        }
        
        control.snp.makeConstraints {
            $0.height.width.equalTo(20)
        }
        
        bag += control.applyBorderColor { _ in
            .brand(.primaryBorderColor)
        }
        
        bag += $isSelected.atOnce().animated(style: .easeOut(duration: 0.25), animations: { isSelected in
            imageView.isHidden = !isSelected
            imageView.tintColor = .brand(.primaryText(true))
            control.backgroundColor = .brand(.primaryBackground(isSelected))
        })
        
        return (control, bag)
    }
}
