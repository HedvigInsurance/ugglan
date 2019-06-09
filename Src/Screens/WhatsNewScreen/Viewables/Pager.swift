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
    
    let onScrolledToEndSignal: Signal<Void>
    let onScrolledToPageSignal: Signal<Int>
    private let onScrolledToEndReadWriteSignal = ReadWriteSignal<Void>(())
    private let onScrolledToPageReadWriteSignal = ReadWriteSignal<Int>(0)
    
    init(
        presentingViewController: UIViewController,
        scrollToNextSignal: ReadSignal<Void>)
    {
        self.presentingViewController = presentingViewController
        self.scrollToNextSignal = scrollToNextSignal
        self.onScrolledToEndSignal = onScrolledToEndReadWriteSignal.plain()
        self.onScrolledToPageSignal = onScrolledToPageReadWriteSignal.plain()
    }
}

extension Pager: Viewable {
     func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let presentingViewControllerSize = presentingViewController.view.bounds.size
        
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: presentingViewControllerSize.width, height: 400)
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        
        bag += dataSignal.atOnce().compactMap { $0?.news }.onValue { news in
            print(news)
            /*
            for (index, newsPage) in news.enumerated() {
                let pagerSlide = PagerSlide(title: newsPage.title, paragraph: newsPage.paragraph, imageUrl: newsPage.illustration.pdfUrl)
                bag += scrollView.add(pagerSlide) { pagerSlideView in
                    pagerSlideView.snp.makeConstraints { make in
                        make.width.height.centerY.equalToSuperview()
                        make.left.equalTo(presentingViewControllerSize.width * CGFloat(index))
                    }
                }
            }*/
            
            for i in 0...3 {
                let pagerSlide = PagerSlide(title: "Page \(i)", paragraph: "Lorem ipsum", imageUrl: news[0].illustration.pdfUrl)
                bag += scrollView.add(pagerSlide) { pagerSlideView in
                    pagerSlideView.snp.makeConstraints { make in
                        make.width.height.centerY.equalToSuperview()
                        make.left.equalTo(presentingViewControllerSize.width * CGFloat(i))
                    }
                }
            }
            
            scrollView.contentSize = CGSize(width: presentingViewControllerSize.width * CGFloat(4 + 1), height: 400)
        }
        
        bag += scrollView.contentOffsetSignal
            .filter(predicate: { $0.x >= scrollView.contentSize.width })
            .map { _ -> Void in () }
            .bindTo(onScrolledToEndReadWriteSignal)
        
        bag += scrollView.contentOffsetSignal
            .filter(predicate: { $0.x.remainder(dividingBy: presentingViewControllerSize.width) == 0 })
            .map { (contentOffset) -> Int in
                Int(floor(contentOffset.x / presentingViewControllerSize.width))
            }
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
