//
//  Welcome.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import StoreKit
import UIKit

struct Welcome {
    let dataSignal: ReadWriteSignal<WelcomeQuery.Data?>

    init(data: WelcomeQuery.Data?) {
        dataSignal = ReadWriteSignal<WelcomeQuery.Data?>(data)
    }
}

extension Welcome: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .formSheetOrOverFullscreen,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )

        let closeButton = CloseButton()

        let item = UIBarButtonItem(viewable: closeButton)
        viewController.navigationItem.rightBarButtonItem = item

        let view = UIView()
        view.backgroundColor = .primaryBackground

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.width.centerX.centerY.equalToSuperview()
            make.height.equalToSuperview().inset(20)
        }

        let scrollToNextCallbacker = Callbacker<Void>()
        let scrolledToPageIndexCallbacker = Callbacker<Int>()
        let scrolledToEndCallbacker = Callbacker<Void>()

        let pager = WelcomePager(
            scrollToNextCallbacker: scrollToNextCallbacker,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker,
            scrolledToEndCallbacker: scrolledToEndCallbacker,
            presentingViewController: viewController
        )

        bag += containerView.addArranged(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
            }
        }

        let controlsWrapper = UIStackView()
        controlsWrapper.axis = .vertical
        controlsWrapper.spacing = 16
        controlsWrapper.distribution = .equalSpacing
        controlsWrapper.isLayoutMarginsRelativeArrangement = true
        controlsWrapper.edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)

        containerView.addArrangedSubview(controlsWrapper)

        controlsWrapper.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

        let pagerDots = WelcomePagerDots()

        bag += controlsWrapper.addArranged(pagerDots) { pagerDotsView in
            pagerDotsView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
        }

        let proceedButton = WelcomePagerProceedButton(
            button: Button(title: "", type: .standard(backgroundColor: .blackPurple, textColor: .white))
        )

        bag += controlsWrapper.addArranged(proceedButton)

        bag += dataSignal.atOnce().bindTo(pager.dataSignal)
        bag += dataSignal.atOnce().compactMap { data in data?.welcome.count }.bindTo(proceedButton.pageAmountSignal)
        bag += dataSignal.atOnce().compactMap { data in data?.welcome.count }.map { count in count + 1 }.bindTo(pagerDots.pageAmountSignal)
        bag += dataSignal.atOnce().bindTo(proceedButton.dataSignal)

        bag += pager.scrolledToPageIndexCallbacker.bindTo(pagerDots.pageIndexSignal)
        bag += pager.scrolledToPageIndexCallbacker.bindTo(proceedButton.onScrolledToPageIndexSignal)

        bag += proceedButton.onTapSignal.onValue {
            scrollToNextCallbacker.callAll()
        }

        viewController.view = view

        return (viewController, Future { completion in
            bag += merge(
                closeButton.onTapSignal,
                scrolledToEndCallbacker.providedSignal
            ).onValue {
                SKStoreReviewController.requestReview()
                completion(.success)
            }

            return bag
        })
    }
}
