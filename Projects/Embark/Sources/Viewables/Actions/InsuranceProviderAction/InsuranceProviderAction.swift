//
//  InsuranceProviderAction.swift
//  Embark
//
//  Created by sam on 3.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import Form
import hCore
import hCoreUI
import UIKit
import Presentation

struct InsuranceProviderAction {
    let state: EmbarkState
    let data: EmbarkPassage.Action.AsEmbarkExternalInsuranceProviderAction
}

extension InsuranceProviderAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let bag = DisposeBag()
        let view = UIView()
        bag += view.applyShadow { _ -> UIView.ShadowProperties in
            UIView.ShadowProperties(
                opacity: 0.25,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        }
        
        return (view, Signal { callback in
            func renderChildViewController() {
                let options: PresentationOptions = [.defaults]
                let (selectionViewController, didPickInsuranceProviderFuture) = InsuranceProviderSelection().materialize()
                
                bag += didPickInsuranceProviderFuture.onValue { provider in
                    self.state.store.setValue(key: "previousInsurer", value: provider.name)
                    callback(self.data.externalInsuranceProviderData.next.fragments.embarkLinkFragment)
                }
                
                let childViewController = selectionViewController.embededInNavigationController(options)
                    
                view.viewController?.addChild(childViewController)
                
                if #available(iOS 13.0, *) {
                    view.viewController?.setOverrideTraitCollection(UITraitCollection(userInterfaceLevel: .elevated), forChild: childViewController)
                }
                
                view.addSubview(childViewController.view)
                
                childViewController.view.snp.makeConstraints { make in
                    make.top.bottom.leading.trailing.equalToSuperview()
                }
                
                childViewController.becomeFirstResponder()
                childViewController.didMove(toParent: view.viewController ?? UIViewController())
                
                childViewController.view.layer.cornerRadius = 8
                
                bag += childViewController.signal(for: \.preferredContentSize).atOnce().animated(style: SpringAnimationStyle.lightBounce()) { size in
                    view.snp.remakeConstraints { make in
                        make.height.equalTo(size.height)
                    }
                    view.layoutIfNeeded()
                    childViewController.view.layoutIfNeeded()
                }
            }
            
            bag += view.didMoveToWindowSignal.take(first: 1).onValue(renderChildViewController)
            
            return bag
        })
    }
}
