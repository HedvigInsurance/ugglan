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
    let superviewSize: CGSize
    let pages: [PagerSlide]
    let scrollToNextSignal: ReadSignal<Void>
}

extension Pager: Viewable {
     func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: superviewSize.width * CGFloat(pages.count + 1), height: 400)
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false

        
        for i in 0 ..< pages.count {
            bag += scrollView.add(pages[i]) { slideView in
                slideView.snp.makeConstraints { make in
                    make.width.height.centerY.equalToSuperview()
                    make.left.equalTo(superviewSize.width * CGFloat(i))
                }
            }
        }
        
        bag += scrollToNextSignal.onValue { _ in
            if (scrollView.contentOffset.x >= (scrollView.contentSize.width - self.superviewSize.width)) {
                return
            }
            
            let newOffset = CGPoint(x: scrollView.contentOffset.x + self.superviewSize.width, y: scrollView.contentOffset.y)

            scrollView.setContentOffset(newOffset, animated: true)
        }
        
        return (scrollView, bag)
    }
}
