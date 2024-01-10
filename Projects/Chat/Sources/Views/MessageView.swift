import Flow
import Foundation
import SwiftUI
import hCoreUI

extension Message: View {
    @ViewBuilder
    public var body: some View {
        HStack {
            messageContent
                .padding(padding)
                .background(bgColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            if case .failed = status {
                hCoreUIAssets.infoIconFilled.view
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.redElement)
            }
        }
    }

    @ViewBuilder
    private var messageContent: some View {
        HStack {
            if case .failed = status {
                hCoreUIAssets.restart.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.redElement)
            }
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
}
