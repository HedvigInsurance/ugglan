import Apollo
import Authentication
import Flow
import Foundation
import Presentation
import SwiftUI
import TestingUtil
import hCore
import hCoreUI
import hGraphQL

struct Debug: View {
    @PresentableStore var store: DebugStore

    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText("OTP Auth Journey")
                }
                .onTap {
                    store.send(.openOTPJourney)
                }
                hRow {
                    hText("OTP Email Entry")
                }
                .onTap {
                    store.send(.openOTPEmailEntry)
                }
                hRow {
                    hText("OTP Code Entry")
                }
                .onTap {
                    store.send(.openOTPCodeEntry)
                }
            }
        }
    }
}

extension Debug {
    static var journey: some JourneyPresentation {
        HostingJourney(
            DebugStore.self,
            rootView: Debug()
        ) { action in
            if action == .openOTPEmailEntry {
                OTPEmailEntry()
                    .disposableHostingJourney
                    .setStyle(.detented(.large))
            } else if action == .openOTPCodeEntry {
                OTPCodeEntry()
                    .disposableHostingJourney
                    .setStyle(.detented(.large))
            } else if action == .openOTPJourney {
                OTPAuthJourney.login { _ in
                    HostingJourney(rootView: hText("Login success")).withJourneyDismissButton
                }
                .setStyle(.detented(.large))
                .mapJourneyDismissToCancel
            }
        }
        .configureTitle("Authentication")
    }
}
