//
//  WhatsNewSlider.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Foundation
import Presentation
import Form
import Flow
import UIKit

struct WhatsNewSlider {
    let dataSignal = ReadWriteSignal<WhatsNewQuery.Data?>(nil)
    let scrollToNextCallbacker: Callbacker<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
    let scrolledToEndCallbacker: Callbacker<Void>
}

extension WhatsNewSlider: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        
        let scrollToNextSignal = scrollToNextCallbacker.signal()
        
        let slider = Slider(
            scrollToNextSignal: scrollToNextSignal,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker,
            scrolledToEndCallbacker: scrolledToEndCallbacker
        )
        
        bag += view.add(slider)
        
        bag += dataSignal
            .atOnce()
            .compactMap { $0?.news }
            .onValue { news in
                let newsSliderPages = news.map { newsPost -> SliderPage in
                    let whatsNewPagerSlide = WhatsNewPagerSlide(
                        title: newsPost.title,
                        paragraph: newsPost.paragraph,
                        imageUrl: newsPost.illustration.pdfUrl
                    )
                    
                    return SliderPage(
                        id: newsPost.title,
                        content: AnyPresentable(whatsNewPagerSlide)
                    )
                }
                
                slider.dataSignal.value = newsSliderPages
            }
        
        return (view, bag)
    }
}
