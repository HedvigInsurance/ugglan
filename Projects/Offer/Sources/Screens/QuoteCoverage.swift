//
//  DetailsSection.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-21.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct QuoteCoverage {
	let quote: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote
}

extension QuoteCoverage: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = "Coverage"
		let bag = DisposeBag()

		let form = FormView()

		bag += form.append(SingleQuoteCoverage(quote: quote))

		form.appendSpacing(.top)

		let scrollView = FormScrollView()
		scrollView.backgroundColor = .brand(.primaryBackground())
		bag += viewController.install(form, scrollView: scrollView)

		return (viewController, bag)
	}
}
