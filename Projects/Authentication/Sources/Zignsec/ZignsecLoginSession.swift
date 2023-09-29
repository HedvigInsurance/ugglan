import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ZignsecLoginSession: View {
    @State var hasOpenedBrowser = false
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
                        VectorPreservedImage(
                            image: hCoreUIAssets.circularCross.image,
                            tint: hSignalColor.redText
                        )
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 25)

                        HStack {
                            hText(L10n.zignsecLoginFailed)
                        }
                    }
                } else {
                    VStack {
                        if !hasOpenedBrowser {
                            Image(systemName: "safari.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.bottom, 25)

                            HStack {
                                hText(L10n.zignsecOpeningBrowser)

                                ActivityIndicator(
                                    style: .large,
                                    color: hTextColor.primary
                                )
                            }
                        } else {
                            VectorPreservedImage(
                                image: hCoreUIAssets.refresh.image,
                                tint: hTextColor.primary
                            )
                            .frame(width: 80, height: 80)
                            .padding(.bottom, 25)

                            HStack {
                                hText(L10n.zignsecWaitingForResponse)

                                ActivityIndicator(
                                    style: .large,
                                    color: hTextColor.primary
                                )
                            }
                        }
                    }
                }
            }
            .padding(.all, 25)
        }
        .taskOnAppear {
            await delay(0.8)
            await UIApplication.shared.open(url)
            await delay(0.25)
            hasOpenedBrowser = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.ignoresSafeArea(.all))
    }
}

struct ZignsecOpenURL_Previews: PreviewProvider {
    static var previews: some View {
        ZignsecLoginSession(url: URL(string: "hedvigtest://test")!)
    }
}
