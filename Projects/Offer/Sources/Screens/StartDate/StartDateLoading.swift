//
//  StartDateLoading.swift
//  Offer
//
//  Created by Sam Pettersson on 2022-02-09.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import hCoreUI
import hCore
import SwiftUI

struct StartDateLoading: ViewModifier {
    func body(content: Content) -> some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.isUpdatingStartDates
            })
            { isUpdatingStartDates in
                content.hButtonIsLoading(isUpdatingStartDates)
            }
    }
}
