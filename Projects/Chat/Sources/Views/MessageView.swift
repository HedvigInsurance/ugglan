import Contracts
import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import hCore
import hCoreUI

struct MessageView: View {
    let message: Message
    @State var height: CGFloat = 0
    @State var width: CGFloat = 0
    @ViewBuilder
    public var body: some View {
        HStack {
            messageContent
                .padding(message.padding)
                .background(message.bgColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .environment(\.colorScheme, .light)
            if case .failed = message.status {
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
            if case .failed = message.status {
                hCoreUIAssets.restart.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.redElement)
            }
            switch message.type {
            case let .text(text):
                ChatTextViewRepresentable(
                    text: text,
                    fixedWidth: 300,
                    height: $height,
                    width: $width
                )
                .frame(width: width, height: height)
            case let .file(file):
                ChatFileView(file: file).frame(maxHeight: 200)
            case let .crossSell(url):
                LinkView(vm: .init(url: url), height: $height, width: $width)
            case let .deepLink(url):
                if let type = DeepLink.getType(from: url) {
                    Button {
                        let store: ChatStore = globalPresentableStoreContainer.get()
                        store.send(.navigation(action: .linkClicked(url: url)))
                    } label: {
                        if #available(iOS 15.0, *) {
                            Text(type.title(displayText: url.contractName ?? type.importantText))
                                .multilineTextAlignment(.leading)
                        } else {
                            hText(type.wholeText(displayText: url.contractName ?? type.importantText))
                        }
                    }
                } else {
                    ChatTextViewRepresentable(
                        text: url.absoluteString,
                        fixedWidth: 300,
                        height: $height,
                        width: $width
                    )
                    .frame(width: width, height: height)
                    .frame(maxWidth: 300)
                }
            case let .otherLink(url):
                LinkView(vm: .init(url: url), height: $height, width: $width)

            case .unknown: Text("")
            }
        }
    }
}

struct LinkView: View {
    @StateObject var vm: LinkViewModel
    @Binding var height: CGFloat
    @Binding var width: CGFloat
    var body: some View {
        if let error = vm.error {
            ChatTextViewRepresentable(
                text: error,
                fixedWidth: 300,
                height: $height,
                width: $width
            )
            .frame(width: width, height: height)
            .frame(maxWidth: 300)
            .padding(16)
            .transition(.opacity)
        } else if let model = vm.webMetaDataProviderData {
            VStack(spacing: 8) {
                Image(uiImage: model.image ?? hCoreUIAssets.hedvigBigLogo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                VStack(spacing: 8) {
                    hText(model.title)
                        .foregroundColor(hTextColor.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    hButton.MediumButton(type: .primaryAlt) {
                        let store: ChatStore = globalPresentableStoreContainer.get()
                        store.send(.navigation(action: .linkClicked(url: vm.url)))
                    } content: {
                        hText(L10n.ImportantMessage.readMore)
                    }

                }
                .padding([.horizontal, .bottom], 16)
            }
            .transition(.opacity)
            .frame(width: 300)
        } else {
            ProgressView()
                .foregroundColor(hTextColor.primary)
                .frame(width: 300, height: 200)
                .transition(.opacity)
        }
    }
}

class LinkViewModel: ObservableObject {
    @Published var webMetaDataProviderData: WebMetaDataProviderData?
    @Published var error: String?
    let url: URL

    init(url: URL) {
        self.url = url
        Task {
            await getData()
        }

    }

    @MainActor
    func getData() {
        Task {
            do {
                if let webMetaDataProviderData = try await WebMetaDataProvider.shared.data(for: url) {
                    withAnimation {
                        self.webMetaDataProviderData = webMetaDataProviderData
                    }
                } else {
                    withAnimation {
                        self.error = url.absoluteString
                    }
                }
            } catch let ex {
                withAnimation {
                    error = ex.localizedDescription
                }
            }
        }
    }

}
extension URL {
    public var contractName: String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        let contractIdString = queryItems.first(where: { $0.name == "contractId" })?.value
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        return contractStore.state.contractForId(contractIdString ?? "")?.currentAgreement?.productVariant.displayName
    }
}
