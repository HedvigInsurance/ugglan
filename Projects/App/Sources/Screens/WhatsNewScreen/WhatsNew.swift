//
//  WhatsNew.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct WhatsNew {
    let dataSignal: ReadWriteSignal<GraphQL.WhatsNewQuery.Data?>

    init(data: GraphQL.WhatsNewQuery.Data?) {
        dataSignal = ReadWriteSignal<GraphQL.WhatsNewQuery.Data?>(data)
    }
}

extension WhatsNew: Presentable {
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

        viewController.displayableTitle = L10n.featurePromoTitle

        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())

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

        let pager = WhatsNewPager(
            scrollToNextCallbacker: scrollToNextCallbacker,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker,
            scrolledToEndCallbacker: scrolledToEndCallbacker
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

        let pagerDots = WhatsNewPagerDots()

        bag += controlsWrapper.addArranged(pagerDots) { pagerDotsView in
            pagerDotsView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
        }

        let proceedButton = ProceedButton(
            button: Button(title: "", type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor)))
        )

        bag += controlsWrapper.addArranged(proceedButton)

        bag += dataSignal.atOnce().bindTo(pager.dataSignal)
        bag += dataSignal.atOnce().compactMap { data in data?.news.count }.bindTo(proceedButton.pageAmountSignal)
        bag += dataSignal.atOnce().compactMap { data in data?.news.count }.map { count in count + 1 }.bindTo(pagerDots.pageAmountSignal)
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
                ApplicationState.setLastNewsSeen()
                completion(.success)
            }

            return bag
        })
    }
}
