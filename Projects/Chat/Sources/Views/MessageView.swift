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
        case let .text(text):
            hText(text).multilineTextAlignment(.leading)
        case let .file(file):
            ChatFileView(file: file).frame(maxHeight: 200)
        case let .crossSell(url): Text("")
        case let .deepLink(url): Text("")
        case let .otherLink(url): Text("")
        case .unknown: Text("")
        }
    }
}
