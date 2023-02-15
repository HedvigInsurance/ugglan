import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import WebKit
import hCore
import hCoreUI

public struct ZignsecOpenURL: View {
    @State var hasOpenedSafari = false
    var url: URL

    public init(
        url: URL
    ) {
        self.url = url
    }

    public var body: some View {
        ZStack(alignment: .center) {
            PresentableStoreLens(
                AuthenticationStore.self,
                getter: { state in
                    state.loginHasFailed
                }
            ) { loginHasFailed in
                if loginHasFailed {
                    VStack {
                        Image(uiImage: hCoreUIAssets.circularCross.image)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.bottom, 25)

                        HStack {
                            hText(L10n.zignsecLoginFailed)
                        }
                    }
                } else {
                    VStack {
                        Image(systemName: "safari.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.bottom, 25)

                        HStack {
                            if !hasOpenedSafari {
                                hText(L10n.zignsecOpeningBrowser)
                            } else {
                                hText(L10n.zignsecWaitingForResponse)
                            }

                            ActivityIndicator(style: .large)
                        }
                    }
                }
            }

        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                UIApplication.shared.open(url)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    hasOpenedSafari = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.secondary.ignoresSafeArea(.all))
    }
}

struct ZignsecOpenURL_Previews: PreviewProvider {
    static var previews: some View {
        ZignsecOpenURL(url: URL(string: "hedvigtest://test")!)
    }
}
