//
//  ReadOTPState.swift
//  Authentication
//
//  Created by Sam Pettersson on 2021-11-15.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCore

struct ReadOTPState<Content: View>: View {
    var content: (_ state: OTPState) -> Content

    init(
        @ViewBuilder _ content: @escaping (_ state: OTPState) -> Content
    ) {
        self.content = content
    }

    var body: some View {
        PresentableStoreLens(
            AuthenticationStore.self,
            getter: { state in
                state.otpState
            }
        ) { state in
            content(state)
        }
    }
}
