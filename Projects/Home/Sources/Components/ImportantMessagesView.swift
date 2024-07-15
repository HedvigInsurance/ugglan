import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ImportantMessageView: View {
    let importantMessage: ImportantMessage
    @PresentableStore var store: HomeStore
    @State var showSafariView = false
    @State var urlLink: URL?
    var body: some View {
        if importantMessage.message != "" {
            if let linkInfo = importantMessage.linkInfo {
                InfoCard(text: importantMessage.message, type: .attention)
                    .buttons(
                        [
                            .init(
                                buttonTitle: L10n.ImportantMessage.hide,
                                buttonAction: {
                                    store.send(.hideImportantMessage(id: importantMessage.id))
                                }
                            ),
                            .init(
                                buttonTitle: linkInfo.text,
                                buttonAction: {
                                    self.urlLink = linkInfo.link
                                    showSafariView = true
                                }
                            ),
                        ]
                    )
                    .sheet(isPresented: $showSafariView) {
                        SafariView(url: $urlLink)
                    }
            } else {
                InfoCard(text: importantMessage.message, type: .attention)
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
