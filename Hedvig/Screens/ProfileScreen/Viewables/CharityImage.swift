//
//  CharityImage.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

struct CharityImage {
    let imageUrl: String
}

extension CharityImage: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        containerView.addSubview(imageView)

        if let imageUrl = URL(string: imageUrl), let data = try? Data(contentsOf: imageUrl) {
            imageView.image = UIImage(data: data)
        }

        imageView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(0)
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(115)
        }

        return (containerView, bag)
    }
}
