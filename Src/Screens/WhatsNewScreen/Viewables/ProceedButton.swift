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
        buttonView.alpha = 0
        
        let buttonTitleSignal = ReadWriteSignal<String>("")
        
        func setButtonStyle (isMorePages: Bool) {
            button.type.value = isMorePages ? ButtonType.standard(backgroundColor: .blackPurple, textColor: .white) : ButtonType.standard(backgroundColor: .purple, textColor: .white)
        }
        
        func setButtonTitle (isMorePages: Bool) {
            buttonTitleSignal.value = isMorePages ? String(key: .NEWS_PROCEED) : String(key: .NEWS_DISMISS)
        }
        
        bag += button.onTapSignal.bindTo(onTapReadWriteSignal)
        
        bag += buttonTitleSignal
            .distinct()
            .delay(by: 0.25)
            .animated(style: SpringAnimationStyle.lightBounce(duration: 0.15)) { title in
                buttonView.setTitle(title)
                
                buttonView.snp.remakeConstraints { make in
                    make.width.equalTo(buttonView.intrinsicContentSize.width + self.button.type.value.extraWidthOffset())
                }
                
                buttonView.layoutIfNeeded()
            }
        
        bag += dataSignal
            .filter(predicate: { $0 != nil })
            .compactMap { $0!.news.count }
            .take(first: 1)
            .onValue { newsCount in
                let isMorePages = newsCount > 1
                
                setButtonTitle(isMorePages: isMorePages)
                setButtonStyle(isMorePages: isMorePages)
                
                buttonView.alpha = 1
        }
        
        bag += onScrolledToPageIndexSignal.onValue { pageIndex in
            if let newsCount = self.dataSignal.value?.news.count {
                let isMorePages = pageIndex < (newsCount - 1)
                    
                setButtonTitle(isMorePages: isMorePages)
                setButtonStyle(isMorePages: isMorePages)
            }
        }
        
        return (buttonView, Disposer {
            disposable.dispose()
            bag.dispose()
        })
    }
}
