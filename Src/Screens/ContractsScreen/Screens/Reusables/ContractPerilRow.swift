//
//  ContractPerilRow.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Flow
import Form
import Foundation
import UIKit

struct ContractPerilRow {}

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
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.houseWaterLeak.image
        contentContainer.addArrangedSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(40)
        }

        let title = UILabel(value: "Peril", style: .headlineMediumMediumLeft)
        contentContainer.addArrangedSubview(title)

        return (view, { _ in
            let bag = DisposeBag()

            bag += view.signal(for: .touchDown).animated(style: .easeOut(duration: 0.25), animations: { _ in
                view.backgroundColor = UIColor.primaryTintColor.withAlphaComponent(0.2)
            })

            bag += view.delayedTouchCancel().animated(style: .easeOut(duration: 0.25), animations: { _ in
                view.backgroundColor = .secondaryBackground
            })

            bag += view.trackedTouchUpInsideSignal.onValue { _ in
                view.viewController?.present(PerilDetail(title: "Peril", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur tincidunt, turpis sit amet gravida vulputate, metus tortor mollis felis, vitae laoreet mi tellus vel sem. Suspendisse suscipit, arcu non iaculis porttitor, odio lorem fermentum risus, eu dignissim enim sapien quis ante. Praesent ultrices, augue eu congue malesuada, tortor odio auctor enim, dictum consequat arcu purus auctor ligula. Vivamus ac facilisis ante. Cras mollis magna ut sapien scelerisque, sit amet malesuada turpis commodo. Ut tempor dolor et elit auctor, ac pellentesque nisl bibendum. Nulla placerat finibus lobortis. In hac habitasse platea dictumst. Nullam pretium odio nibh, sed elementum mi volutpat scelerisque. Vestibulum sed tristique justo. Duis ullamcorper eros eros, nec suscipit ipsum pretium varius. Vivamus dolor metus, placerat ut euismod vel, molestie id leo."))
            }

            return bag
        })
    }
}
