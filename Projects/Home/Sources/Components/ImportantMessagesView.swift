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
                state.importantMessage
            }
        ) { importantMessage in
            if let importantMessage = importantMessage {
                hSection {
                    Button(
                        action: {
                            if let url = URL(string: importantMessage.link ?? "") {
                                self.url = url
                                showSafariView = true
                            }
                        },
                        label: {
                            hRow {
                                HStack {
                                    hText(importantMessage.message ?? "", style: .subheadline)
                                        .foregroundColor(hLabelColor.secondary.colorFor(.light, .base))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(uiImage: hCoreUIAssets.arrowForward.image).foregroundColor(.black)
                                }
                            }
                            .verticalPadding(12)
                        }
                    )
                    .sheet(isPresented: $showSafariView) {
                        SafariView(url: $url)
                    }
                }
                .withoutHorizontalPadding.sectionContainerStyle(.caution(useNewDesign: false))
            }
        }
    }
}
