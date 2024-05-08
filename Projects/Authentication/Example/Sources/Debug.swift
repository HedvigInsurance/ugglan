import Apollo
import Authentication
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
