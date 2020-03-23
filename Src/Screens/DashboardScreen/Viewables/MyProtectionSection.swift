//
//  DashboardSection.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-31.
//

import Flow
import Form
import Foundation
import UIKit

struct MyProtectionSection {
    let dataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
}

extension MyProtectionSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isHidden = true
        bag += dataSignal.map { $0 == nil }.bindTo(stackView, \.isHidden)

        let isActiveLabel = MultilineLabelIcon(
            styledText: StyledText(
                text: String(key: .DASHBOARD_INSURANCE_STATUS),
                style: .rowSubtitle
            ),
            icon: Asset.circularCheckmark,
            iconWidth: 15
        )

        bag += stackView.addArranged(isActiveLabel) { checkmarkLabelView in
            bag += dataSignal.atOnce().compactMap { !($0?.status == .active) }.bindTo(checkmarkLabelView, \.isHidden)
        }

        let rowSpacing = Spacing(height: 10)
        bag += stackView.addArranged(rowSpacing) { spacing in
            bag += dataSignal.atOnce().compactMap { !($0?.status == .active) }.bindTo(spacing, \.isHidden)
        }

        let perilCategoriesStack = UIStackView()
        perilCategoriesStack.axis = .vertical
        stackView.addArrangedSubview(perilCategoriesStack)

        bag += dataSignal.atOnce().compactMap { $0?.arrangedPerilCategories }.onValue { perilCategories in
            perilCategoriesStack.subviews.forEach { view in
                view.removeFromSuperview()
            }

            if let home = perilCategories.home {
                let protectionSection = PerilExpandableRow(
                    perilsCategory: .home,
                    presentingViewController: self.presentingViewController
                )
                protectionSection.perilsDataSignal.value = home.fragments.perilCategoryFragment
                bag += perilCategoriesStack.addArranged(protectionSection)
                bag += perilCategoriesStack.addArranged(rowSpacing)
            }

            if let me = perilCategories.me {
                let protectionSection = PerilExpandableRow(
                    perilsCategory: .me,
                    presentingViewController: self.presentingViewController
                )
                protectionSection.perilsDataSignal.value = me.fragments.perilCategoryFragment
                bag += perilCategoriesStack.addArranged(protectionSection)
                bag += perilCategoriesStack.addArranged(rowSpacing)
            }

            if let stuff = perilCategories.stuff {
                let protectionSection = PerilExpandableRow(
                    perilsCategory: .stuff,
                    presentingViewController: self.presentingViewController
                )
                protectionSection.perilsDataSignal.value = stuff.fragments.perilCategoryFragment
                bag += perilCategoriesStack.addArranged(protectionSection)
                bag += perilCategoriesStack.addArranged(rowSpacing)
            }

            let moreInfoSection = MoreInfoExpandableRow()
            bag += perilCategoriesStack.addArranged(moreInfoSection)
        }

        return (stackView, bag)
    }
}
