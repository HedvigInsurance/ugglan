//
//  WhatsNew.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

struct WhatsNew {
    let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )
}

extension WhatsNew: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()

        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .overFullScreen,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )
        
        let dismissButton = DismissButton()
        
        let item = UIBarButtonItem(viewable: dismissButton)
        viewController.navigationItem.rightBarButtonItem = item
        
        viewController.displayableTitle = "Vad är nytt?"
        
        let view = UIView()
        view.backgroundColor = .offWhite
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.edgeInsets = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 24,
            right: 0
        )
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.width.centerY.centerX.equalToSuperview()
        }
        
        let pages: [PagerSlide] = [
            PagerSlide(title: "Bonusregn till folket!", body: "Hedvig blir bättre när du får dela det med dina vänner! Du och dina vänner får 10 kr lägre månadskostnad – för varje vän!"),
            PagerSlide(title: "Bonusregn till folket 2 ", body: "Lorem 2")
        ]
    
        let pager = Pager(superviewSize: viewController.view.bounds.size, pages: pages)
        
        bag += stackView.addArranged(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.height.equalTo(480)
            }
        }
        
        
        let pageIndicator = PageIndicator(numberOfPages: 6)
     
        bag += stackView.addArranged(pageIndicator) { pageIndicatorView in
            pageIndicatorView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(40)
            }
        }
        
        let button = Button(title: "Nästa nyhet", type: .standard(backgroundColor: .purple, textColor: .white))
        
        let buttonContainer = UIView()
        
        bag += buttonContainer.add(button) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.height.centerY.centerX.equalToSuperview()
            }
        }
        
        stackView.addArrangedSubview(buttonContainer)
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += dismissButton.onTapSignal.onValue { _ in
                completion(.success)
            }
            
            return bag
        })
    }
}
