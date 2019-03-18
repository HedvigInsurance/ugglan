//
//  ReferralsIllustration.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Flow
import Foundation
import UIKit

struct ReferralsIllustration {}

extension ReferralsIllustration: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = Asset.referralsIllustration.image
        imageView.contentMode = .scaleAspectFill

        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.center.equalToSuperview()
            make.height.equalToSuperview()
        }

        return (view, NilDisposer())
    }
}
