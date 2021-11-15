//
//  OTPCodeLoadingOverlay.swift
//  Authentication
//
//  Created by Sam Pettersson on 2021-11-15.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import SwiftUI
import hCoreUI

struct OTPCodeLoadingOverlay: View {
    var body: some View {
        PresentableStoreLens(
            AuthenticationStore.self,
            getter: { state in
                state.otpState.isLoading
            }
        ) { isLoading in
            if isLoading {
                HStack {
                    WordmarkActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hBackgroundColor.primary.opacity(0.7))
                .cornerRadius(.defaultCornerRadius)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .presentableStoreLensAnimation(.default)
    }
}
