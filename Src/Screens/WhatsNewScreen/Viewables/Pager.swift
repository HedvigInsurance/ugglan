//
//  Pager.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Foundation
import Form
import Flow
import UIKit

struct Pager {
    let presentingViewController: UIViewController
    let scrollToNextSignal: ReadSignal<Void>
    let dataSignal: ReadWriteSignal<WhatsNewQuery.Data?> = ReadWriteSignal(nil)
    
    let onScrolledToPageSignal: Signal<Int>
    let onScrolledToEndCallbacker: Callbacker<Void>
    private let onScrolledToPageReadWriteSignal = ReadWriteSignal<Int>(0)
    
    init(
        presentingViewController: UIViewController,
        scrollToNextSignal: ReadSignal<Void>)
    {
        self.presentingViewController = presentingViewController
        self.scrollToNextSignal = scrollToNextSignal
        self.onScrolledToEndCallbacker = Callbacker<Void>()
        self.onScrolledToPageSignal = onScrolledToPageReadWriteSignal.plain()
    }
}

extension Pager: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let presentingViewControllerSize = presentingViewController.view.bounds.size
        
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 0, height: 0)
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        
        bag += dataSignal.atOnce().compactMap { $0?.news }.onValue { news in
            for (index, newsPage) in news.enumerated() {
                let pagerSlide = PagerSlide(title: newsPage.title, paragraph: newsPage.paragraph, imageUrl: newsPage.illustration.pdfUrl)
                bag += scrollView.add(pagerSlide) { pagerSlideView in
                    pagerSlideView.snp.makeConstraints { make in
                        make.width.height.centerY.equalToSuperview()
                        make.left.equalTo(presentingViewControllerSize.width * CGFloat(index))
                    }
                }
            }
            
            scrollView.contentSize = CGSize(width: presentingViewControllerSize.width * CGFloat(news.count + 1), height: 0)
        }
        
        bag += scrollView.contentOffsetSignal
            .filter(predicate: { $0.x >= scrollView.contentSize.width - presentingViewControllerSize.width && scrollView.contentSize.width != 0 })
            .onValue { _ in
                self.onScrolledToEndCallbacker.callAll()
        }
        
        bag += scrollView.contentOffsetSignal
            .filter(predicate: { $0.x.remainder(dividingBy: presentingViewControllerSize.width) == 0 })
            .map { (contentOffset) -> Int in
                Int(floor(contentOffset.x / presentingViewControllerSize.width))
            }
            .distinct()
            .bindTo(onScrolledToPageReadWriteSignal)
        
        bag += scrollToNextSignal.onValue { _ in
            if (scrollView.contentOffset.x >= (scrollView.contentSize.width - presentingViewControllerSize.width)) {
                return
            }
            
            let newOffset = CGPoint(x: scrollView.contentOffset.x + presentingViewControllerSize.width, y: scrollView.contentOffset.y)
            
            scrollView.setContentOffset(newOffset, animated: true)
        }
        
        return (scrollView, bag)
    }
}
