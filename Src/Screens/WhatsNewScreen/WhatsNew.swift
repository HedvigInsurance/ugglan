//
//  WhatsNew.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Apollo
import Foundation
import Flow
import Form
import Presentation
import UIKit

struct WhatsNew {
    let dataSignal: ReadWriteSignal<WhatsNewQuery.Data?>
    
    init(data: WhatsNewQuery.Data?) {
        self.dataSignal = ReadWriteSignal<WhatsNewQuery.Data?>(data)
    }
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
        
        let closeButton = CloseButton()
        
        let item = UIBarButtonItem(viewable: closeButton)
        viewController.navigationItem.rightBarButtonItem = item
        
        viewController.displayableTitle = String(key: .FEATURE_PROMO_TITLE)
        
        let view = UIView()
        view.backgroundColor = .offWhite
        
        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.edgeInsets = UIEdgeInsets(
            top: 25,
            left: 0,
            bottom: 25,
            right: 0
        )
        
        containerView.addArrangedSubview(stackView)
        
        let scrollToNextSignal = ReadWriteSignal<Void>(())
        
        let whatsNewSlider = WhatsNewSlider()
        
        bag += dataSignal.atOnce().compactMap { $0 }.bindTo(whatsNewSlider.dataSignal)
        
        bag += stackView.addArranged(whatsNewSlider) { sliderView in
            sliderView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.height.equalTo(400)
            }
        }
        
        /*
        let pager = Pager(presentingViewController: viewController, scrollToNextSignal: scrollToNextSignal.readOnly())
        
        bag += stackView.addArranged(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.height.lessThanOrEqualTo(390)
            }
        }*/
        
        let pageIndicatorSpacing = Spacing(height: 20)
        bag += stackView.addArranged(pageIndicatorSpacing)
       
        let pageIndicator = PageIndicator()
        
        bag += stackView.addArranged(pageIndicator) { pageIndicatorView in
            pageIndicatorView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(40)
            }
        }
        
        let proceedButton = ProceedButton(
            button: Button(title: "", type: .standard(backgroundColor: .blackPurple, textColor: .white))
        )
        
        bag += stackView.addArranged(proceedButton) { proceedButtonView in
            proceedButtonView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
            }
        }
        
        // bag += dataSignal.atOnce().bindTo(pager.dataSignal)
        bag += dataSignal.atOnce().bindTo(pageIndicator.dataSignal)
        bag += dataSignal.atOnce().bindTo(proceedButton.dataSignal)
        
        // bag += pager.onScrolledToPageSignal.bindTo(pageIndicator.pageIndexSignal)
        // bag += pager.onScrolledToPageSignal.bindTo(proceedButton.onScrolledToPageIndexSignal)
        
        bag += proceedButton.onTapSignal.map { _ -> Void in () }.bindTo(scrollToNextSignal)
        bag += proceedButton.onTapSignal.map { _ -> Void in () }.bindTo(whatsNewSlider.scrollToNextSignal)
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += merge(
                closeButton.onTapSignal
                //pager.onScrolledToEndCallbacker.signal()
            ).onValue {
                ApplicationState.setLastNewsSeen()
                completion(.success)
            }
            
            return bag
        })
    }
}
