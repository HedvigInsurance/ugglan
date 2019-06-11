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
    let client: ApolloClient
    let environment: ApolloEnvironmentConfig
    let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )
    
    init(client: ApolloClient = ApolloContainer.shared.client, environment: ApolloEnvironmentConfig = ApolloContainer.shared.environment) {
        self.client = client
        self.environment = environment
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
        
        let dismissButton = DismissButton()
        
        let item = UIBarButtonItem(viewable: dismissButton)
        viewController.navigationItem.rightBarButtonItem = item
        
        viewController.displayableTitle = "Vad är nytt?"
        
        let view = UIView()
        view.backgroundColor = .offWhite
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.edgeInsets = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 24,
            right: 0
        )
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.width.centerX.centerY.equalToSuperview()
        }
        
        let scrollToNextSignal = ReadWriteSignal<Void>(())
        
        let pager = Pager(presentingViewController: viewController, scrollToNextSignal: scrollToNextSignal.readOnly())
        
        bag += stackView.addArranged(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.height.equalTo(480)
            }
        }
       
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
        
        let whatsNewQuery = client.watch(query: WhatsNewQuery(locale: Locale.svSe, sinceVersion: "2.7.0"))
            .compactMap { $0.data }
        
        bag += whatsNewQuery.bindTo(pager.dataSignal)
        bag += whatsNewQuery.bindTo(pageIndicator.dataSignal)
        bag += whatsNewQuery.bindTo(proceedButton.dataSignal)
        
        bag += pager.onScrolledToPageSignal.bindTo(pageIndicator.pageIndexSignal)
        bag += pager.onScrolledToPageSignal.bindTo(proceedButton.onScrolledToPageIndexSignal)
        
        bag += proceedButton.onTapSignal.map { _ -> Void in () }.bindTo(scrollToNextSignal)
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += merge(
                dismissButton.onTapSignal,
                pager.onScrolledToEndSignal
            ).onValue {
                completion(.success)
            }
            
            return bag
        })
    }
}
