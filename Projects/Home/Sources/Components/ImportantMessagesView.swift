import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ImportantMessagesView: View {
    @PresentableStore var store: HomeStore
    @State var showSafariView = false
    @State var urlLink: URL?
    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.importantMessage
            }
        ) { importantMessage in
            if let importantMessage, let message = importantMessage.message {
                if let link = importantMessage.link, let urlLink = URL(string: link) {
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
                                        self.urlLink = urlLink
                                        showSafariView = true
                                    }
                                ),
                            ]
                        )
                        .sheet(isPresented: $showSafariView) {
                            SafariView(url: $urlLink)
                        }
                } else {
                    InfoCard(text: message, type: .attention)
                }
            }
        }
    }
}
