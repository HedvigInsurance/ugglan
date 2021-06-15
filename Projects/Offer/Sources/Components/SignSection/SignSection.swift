//
//  SignSection.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct SignSection {}

extension SignSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
		let bag = DisposeBag()

		let row = RowView()
		section.append(row)

		let signButton = Button(
			title: L10n.offerSignButton,
			type: .standardIcon(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor),
				icon: .left(image: hCoreUIAssets.bankIdLogo.image, width: 20)
			)
		)

		bag += signButton.onTapSignal.onValue { _ in

		}

		bag += row.append(signButton)

		return (section, bag)
	}
}
