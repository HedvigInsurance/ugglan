import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ImportantMessageView: View {
    let importantMessage: ImportantMessage
    @PresentableStore var store: HomeStore
    @State var showSafariView = false
    @State var urlLink: URL?
    var body: some View {
        if let message = importantMessage.message {
            if let link = importantMessage.link, let urlLink = URL(string: link) {
                InfoCard(text: message, type: .attention)
                    .buttons(
                        [
                            .init(
                                buttonTitle: L10n.ImportantMessage.hide,
                                buttonAction: {
                                    store.send(.hideImportantMessage(id: importantMessage.id))
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
                    .buttons(
                        [
                            .init(
                                buttonTitle: L10n.ImportantMessage.hide,
                                buttonAction: {
                                    store.send(.hideImportantMessage(id: importantMessage.id))
                                }
                            )
                        ]
                    )
            }
        }
    }
}
