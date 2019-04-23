//
//  ClaimsHeader.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-04-23.
//

import Foundation
import Flow
import UIKit
import Form

struct ClaimsHeader {
    struct Title {}
    struct Description {}
}

extension ClaimsHeader.Title: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let bag = DisposeBag()
        
        let label = MultilineLabel(
            value: "Har det hänt något? Starta anmälan här!",
            style: TextStyle.standaloneLargeTitle.centered()
        )
        
        bag += view.addArangedSubview(label) { view in
            view.snp.makeConstraints({ make in
                make.width.equalToSuperview().multipliedBy(0.7)
            })
        }
        
        return (view, bag)
    }
}

extension ClaimsHeader.Description: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        
        let bag = DisposeBag()
        
        let label = MultilineLabel(
            value: "Har du tappat telefonen eller råkat ut för en stöld? Anmäl det till Hedvig",
            style: TextStyle.body.centered()
        )
        
        bag += view.addArangedSubview(label) { view in
            view.snp.makeConstraints({ make in
                make.width.equalToSuperview().multipliedBy(0.7)
            })
        }
        
        return (view, bag)
    }
}

extension ClaimsHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()
        
        let imageView = UIImageView()
        imageView.image = Asset.claimsHeader.image
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(185)
        }
        
        view.addArrangedSubview(imageView)
        
        let title = Title()
        bag += view.addArangedSubview(title)
        
        let description = Description()
        bag += view.addArangedSubview(description)
        
        let button = Button(title: "Anmäl skada", type: .standard(backgroundColor: .purple, textColor: .white))
        bag += view.addArangedSubview(button.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }
        
        return (view, bag)
    }
}
