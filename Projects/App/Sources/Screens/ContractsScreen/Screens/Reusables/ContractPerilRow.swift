//
//  ContractPerilRow.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Flow
import Form
import Foundation
import hCoreUI
import Presentation
import UIKit

extension PerilFragment: Equatable {
    public static func == (lhs: PerilFragment, rhs: PerilFragment) -> Bool {
        lhs.title == rhs.title
    }
}

struct ContractPerilRow: Hashable, Equatable {
    static func == (lhs: ContractPerilRow, rhs: ContractPerilRow) -> Bool {
        lhs.fragment == rhs.fragment
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fragment.title)
    }

    let presentDetailStyle: PresentationStyle
    let fragment: PerilFragment
}

extension ContractPerilRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (ContractPerilRow) -> Disposable) {
        let view = UIControl()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 5

        let contentContainer = UIStackView()
        contentContainer.spacing = 10
        contentContainer.axis = .horizontal
        contentContainer.isUserInteractionEnabled = false
        contentContainer.layoutMargins = UIEdgeInsets(inset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.alignment = .center
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (view, { `self` in
            let bag = DisposeBag()

            let remoteVectorIcon = RemoteVectorIcon(self.fragment.icon.fragments.iconFragment, threaded: true)
            bag += contentContainer.addArranged(remoteVectorIcon) { iconView in
                iconView.snp.makeConstraints { make in
                    make.width.height.equalTo(40)
                }
            }

            let title = MultilineLabel(value: self.fragment.title, style: TextStyle.headlineSmallSmallLeft)
            bag += contentContainer.addArranged(title)

            bag += view.signal(for: .touchDown).animated(style: .easeOut(duration: 0.25), animations: { _ in
                view.backgroundColor = UIColor.primaryTintColor.withAlphaComponent(0.2)
            })

            bag += view.delayedTouchCancel().animated(style: .easeOut(duration: 0.25), animations: { _ in
                view.backgroundColor = .secondaryBackground
            })

            bag += view.trackedTouchUpInsideSignal.onValue { _ in
                let detail = PerilDetail(title: self.fragment.title, description: self.fragment.description, icon: remoteVectorIcon)
                view.viewController?.present(detail, style: self.presentDetailStyle)
            }

            return bag
        })
    }
}
