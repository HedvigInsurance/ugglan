import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ImportantMessagesView: View {
    @PresentableStore var store: HomeStore

    @State var showSafariView = false
    @State var url: URL? = URL(string: "")

    public init() {
        store.send(.fetchImportantMessages)
    }

    public var hasActiveInfoCard: Bool {
        if ImportantMessageModel().hasImportantMessage {
            return true
        }
        return false
    }

    struct ImportantMessageModel {
        var hasImportantMessage: Bool = false
        var hasLink: Bool = false
        var message: String = ""
        var url: URL?

        init() {
            let homeStore: HomeStore = globalPresentableStoreContainer.get()
            let state = homeStore.state

            let importantMessage = state.importantMessage
            let hideImportantMessage = state.hideImportantMessage

            if let importantMessage = importantMessage, let message = importantMessage.message, !hideImportantMessage {
                hasImportantMessage = true
                self.message = message
                if let stringUrl = importantMessage.link, let urlString = URL(string: stringUrl) {
                    hasLink = true
                    self.url = urlString
                }
            }
        }
    }

    var body: some View {
        if ImportantMessageModel().hasImportantMessage {
            if ImportantMessageModel().hasLink {
                InfoCard(text: ImportantMessageModel().message, type: .attention)
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
                                    self.url = ImportantMessageModel().url
                                    showSafariView = true
                                }
                            ),
                        ]
                    )
                    .sheet(isPresented: $showSafariView) {
                        SafariView(url: $url)
                    }
            } else {
                InfoCard(text: ImportantMessageModel().message, type: .attention)
            }
        }
    }
}
