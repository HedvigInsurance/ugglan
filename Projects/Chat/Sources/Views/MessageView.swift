import Flow
import Foundation
import SwiftUI
import hCoreUI

extension Message: View {
    @ViewBuilder
    public var body: some View {
        messageContent
            .padding(padding)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    var messageContent: some View {
        switch self.type {
        case let .text(text): hText(text).multilineTextAlignment(.leading)
        case let .file(file):
            FileView(file: file) {
                if let topVC = UIApplication.shared.getTopViewController() {
                    let disposeBag = DisposeBag()
                    switch file.source {
                    case let .localFile(url, _):
                        let preview = DocumentPreview(url: url)
                        disposeBag += topVC.present(preview.journey)
                    case .url(let url):
                        let preview = DocumentPreview(url: url)
                        disposeBag += topVC.present(preview.journey)
                    }
                }
            }
        case let .crossSell(url): Text("")
        case let .deepLink(url): Text("")
        case let .otherLink(url): Text("")
        case .unknown: Text("")
        }
    }
}
