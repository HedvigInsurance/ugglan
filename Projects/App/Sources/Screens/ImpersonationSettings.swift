//
//  ImpersonationSettings.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2022-03-03.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCore
import hCoreUI
import Presentation

struct ImpersonationSettings: View {
    @PresentableStore var store: UgglanStore
    
    var body: some View {
        hForm {
            hSection(header: hText("Select locale")) {
                ForEach(Localization.Locale.allCases, id: \.rawValue) { locale in
                    hRow {
                        hText(locale.rawValue)
                    }
                    .onTap {
                        Localization.Locale.currentLocale = locale
                        ApplicationState.preserveState(.loggedIn)
                        UIApplication.shared.appDelegate.logout()
                    }
                }
            }.withFooter {
                hText("BEWARE: if you select a locale that doesn't match the market of the user weird things will happen.")
            }
        }
    }
}
