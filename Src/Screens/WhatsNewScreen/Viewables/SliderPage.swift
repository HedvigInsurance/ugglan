//
//  SliderPage.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import DeviceKit
import Flow
import Form
import Presentation
import Foundation
import UIKit

struct SliderPage {
    let id: String
    let content: AnyPresentable<UIViewController, Disposable>
    
    init (id: String, content: AnyPresentable<UIViewController, Disposable>) {
        self.id = id
        self.content = content
    }
}

extension SliderPage: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (SliderPage) -> Disposable) {
        let sliderPageView = UIView()
        
        return (sliderPageView, { sliderPage in
            sliderPageView.subviews.forEach { view in
                view.removeFromSuperview()
            }
            
            let (contentScreen, contentDisposable) = sliderPage.content.materialize()
            
            sliderPageView.addSubview(contentScreen.view)
            
            contentScreen.view.snp.makeConstraints { make in
                make.width.height.equalToSuperview()
            }            

            return contentDisposable
        })
    }
}
