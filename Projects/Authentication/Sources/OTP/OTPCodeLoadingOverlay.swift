import SwiftUI
import hCore
import hCoreUI

struct OTPCodeLoadingOverlay: View {
    @ObservedObject var otpVM: OTPState

    var body: some View {
        if otpVM.isLoading {
            HStack {
                WordmarkActivityIndicator(.standard)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hBackgroundColor.primary.opacity(0.7))
            .cornerRadius(.cornerRadiusL)
            .edgesIgnoringSafeArea(.top)
        }
    }
}
