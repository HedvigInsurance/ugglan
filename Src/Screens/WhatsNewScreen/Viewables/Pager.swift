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
}

extension Pager: Viewable {
     func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let slides: [PagerSlide] = [
            PagerSlide(title: "Bonusregn till folket!", body: "Hedvig blir bättre när du får dela det med dina vänner! Du och dina vänner får 10 kr lägre månadskostnad – för varje vän!"),
            PagerSlide(title: "Bonusregn till folket 2 ", body: "Lorem 2")
        ]
        
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: superviewSize.width * CGFloat(slides.count), height: 400)
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = false
        
        for i in 0 ..< slides.count {
            bag += scrollView.add(slides[i]) { slideView in
                slideView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                    make.left.equalTo(superviewSize.width * CGFloat(i))
                }
            }
        }
        
        return (scrollView, bag)
    }
}
