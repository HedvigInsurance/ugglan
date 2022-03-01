import Foundation
import SwiftUI
import hCore
import hCoreUI

struct StartDateLoading: ViewModifier {
    func body(content: Content) -> some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.isUpdatingStartDates
            }
        ) { isUpdatingStartDates in
            content.hButtonIsLoading(isUpdatingStartDates)
        }
    }
}
