import Foundation
import SwiftUI
import hCore
import hCoreUI

struct OTPCodeLoadingOverlay: View {
    @ObservedObject var otpVM: OTPState

    var body: some View {
        //        PresentableStoreLens(
        //            AuthenticationStore.self,
        //            getter: { state in
        //                state.otpState.isLoading
        //            }
        //        ) { isLoading in
        if otpVM.isLoading {
            HStack {
                WordmarkActivityIndicator(.standard)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hBackgroundColor.primary.opacity(0.7))
            .cornerRadius(.defaultCornerRadius)
            .edgesIgnoringSafeArea(.top)
            .presentableStoreLensAnimation(.default)
        }

    }
}
