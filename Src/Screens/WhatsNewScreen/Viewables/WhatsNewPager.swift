//
//  WhatsNewPager.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Foundation
import Presentation
import Form
import Flow
import UIKit

struct DummyPagerScreen {}

extension DummyPagerScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        return (viewController, bag)
    }
}

struct WhatsNewPager {
    let dataSignal = ReadWriteSignal<WhatsNewQuery.Data?>(nil)
    let scrollToNextCallbacker: Callbacker<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
    let scrolledToEndCallbacker: Callbacker<Void>
}

extension WhatsNewPager: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        
        let scrollToNextSignal = scrollToNextCallbacker.signal()
        
        let pager = Pager(
            scrollToNextSignal: scrollToNextSignal,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker,
            scrolledToEndCallbacker: scrolledToEndCallbacker
        )
        
        bag += view.add(pager)
        
        bag += dataSignal
            .atOnce()
            .compactMap { $0?.news }
            .onValue { news in
                var newsPagerScreens = news.map { newsPost -> PagerScreen in
                    let whatsNewPagerScreen = WhatsNewPagerScreen(
                        title: newsPost.title,
                        paragraph: newsPost.paragraph,
                        imageUrl: newsPost.illustration.pdfUrl
                    )
                    
                    return PagerScreen(
                        id: UUID(),
                        content: AnyPresentable(whatsNewPagerScreen)
                    )
                }
                
                newsPagerScreens.append(PagerScreen(id: UUID(), content: AnyPresentable(DummyPagerScreen())))
                
                pager.dataSignal.value = newsPagerScreens
            }
        
        return (view, bag)
    }
}
