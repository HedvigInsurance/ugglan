import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ImportantMessagesView: View {
    @PresentableStore var store: HomeStore

    @State var showSafariView = false
    @State var url: URL? = URL(string: "")

    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                return state.hideImportantMessage
            }
        ) { hideImportantMessage in
            PresentableStoreLens(
                HomeStore.self,
                getter: { state in
                    return state.importantMessage
                }
            ) { importantMessage in
                if let importantMessage = importantMessage, let message = importantMessage.message,
                    !hideImportantMessage
                {
                    if let stringUrl = importantMessage.link, let url = URL(string: stringUrl) {
                        InfoCard(text: message, type: .attention)
                            .buttons(
                                [
                                    .init(
                                        buttonTitle: L10n.ImportantMessage.hide,
                                        buttonAction: {
                                            store.send(.hideImportantMessage)
                                        }
                                    ),
                                    .init(
                                        buttonTitle: L10n.ImportantMessage.readMore,
                                        buttonAction: {
                                            self.url = url
                                            showSafariView = true
                                        }
                                    ),
                                ]
                            )
                            .sheet(isPresented: $showSafariView) {
                                SafariView(url: $url)
                            }
                    } else {
                        InfoCard(text: message, type: .attention)
                    }
                }
            }
        }
        .presentableStoreLensAnimation(.default)
    }
}
