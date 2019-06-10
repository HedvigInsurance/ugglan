//
//  ProceedButton.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-10.
//

import Flow
import Form
import Foundation

struct ProceedButton {
    let button: Button
    let onTapSignal: Signal<Void>
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())
    
    let dataSignal: ReadWriteSignal<WhatsNewQuery.Data?> = ReadWriteSignal(nil)
    let onScrolledToPageIndexSignal = ReadWriteSignal<Int>(0)
    
    init (button: Button) {
        self.button = button
        self.onTapSignal = onTapReadWriteSignal.plain()
    }
}

extension ProceedButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
        let bag = DisposeBag()
        let (buttonView, disposable) = button.materialize(events: events)
        
        let buttonTitleSignal = ReadWriteSignal<String>("")
        let isMoreNewsSignal = ReadWriteSignal<Bool>(false)
        
        bag += button.onTapSignal.bindTo(onTapReadWriteSignal)
        
        bag += buttonTitleSignal.distinct().animated(style: AnimationStyle.easeOut(duration: 0.25)) { title in
            buttonView.setTitle(title)
            
            buttonView.snp.remakeConstraints { make in
                make.width.equalTo(buttonView.intrinsicContentSize.width + self.button.type.extraWidthOffset())
            }
            
            buttonView.layoutIfNeeded()
        }
        
        bag += isMoreNewsSignal
            .map { (isMoreNews) -> ButtonStyle in
                return isMoreNews ? .standardBlackPurple : .standardPurple
            }.bindTo(
                transition: buttonView,
                style: TransitionStyle.crossDissolve(duration: 0.25),
                buttonView,
                \.style
        )
        
        bag += dataSignal
            .filter(predicate: { $0 != nil })
            .compactMap { $0!.news.count }
            .take(first: 1)
            .onValue { newsCount in
                let isMoreNews = 4 > 1
                
                buttonTitleSignal.value = isMoreNews ? "Next" : "Go to app"
                isMoreNewsSignal.value = isMoreNews
        }
        
        bag += onScrolledToPageIndexSignal.onValue { pageIndex in
            if let newsCount = self.dataSignal.value?.news.count {
                buttonTitleSignal.value = (pageIndex >= (4 - 1)) ? "Go to app" : "Next"
                isMoreNewsSignal.value = (pageIndex < (4 - 1))
            }
        }
        
        return (buttonView, Disposer {
            disposable.dispose()
            bag.dispose()
        })
    }
}
