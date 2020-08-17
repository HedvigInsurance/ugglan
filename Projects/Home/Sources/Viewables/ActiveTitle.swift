//
//  ActiveTitle.swift
//  Home
//
//  Created by Sam Pettersson on 2020-08-17.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct ActiveTitle {
    @Inject var client: ApolloClient
}

extension ActiveTitle: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()

        bag += section.append(MultilineLabel(
            value: "",
            style: .brand(.largeTitle(color: .primary))
        ))

        return (section, bag)
    }
}
