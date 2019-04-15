//
//  Feedback.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit

struct Feedback {}

extension Feedback: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        viewController.title = String(key: .FEEDBACK_SCREEN_TITLE)

        let form = FormView()

        let feedbackHeader = FeedbackHeader()
        bag += form.add(feedbackHeader)

        bag += form.prepend(Spacing(height: feedbackHeader.height))

        let feedbackSection = form.appendSection(
            headerView: nil,
            footerView: nil,
            style: .sectionPlain
        )

        let reportBugRow = ReportBugRow(presentingViewController: viewController)
        bag += feedbackSection.append(reportBugRow)

        let reviewAppRow = ReviewAppRow()
        bag += feedbackSection.append(reviewAppRow)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
