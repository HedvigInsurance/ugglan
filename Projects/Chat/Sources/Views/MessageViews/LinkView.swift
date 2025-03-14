import SwiftUI
import hCore
import hCoreUI

struct LinkView: View {
    @StateObject var vm: LinkViewModel
    @State var height: CGFloat = 0
    @State var width: CGFloat = 0
    var body: some View {
        if let error = vm.error {
            MarkdownView(
                config: .init(
                    text: error,
                    fontStyle: .body1,
                    color: hTextColor.Opaque.primary,
                    linkColor: hTextColor.Opaque.primary,
                    linkUnderlineStyle: .thick,
                    maxWidth: 300,
                    onUrlClicked: { url in
                        NotificationCenter.default.post(name: .openDeepLink, object: url)
                    }
                )
            )
            .padding(.padding16)
            .transition(.opacity)
        } else if let model = vm.webMetaDataProviderData {
            VStack(spacing: .padding8) {
                Image(uiImage: model.image ?? hCoreUIAssets.helipadOutlined.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 200)
                VStack(spacing: .padding8) {
                    hText(model.title)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    hButton.MediumButton(type: .primaryAlt) {
                        NotificationCenter.default.post(name: .openDeepLink, object: vm.url)
                    } content: {
                        hText(L10n.ImportantMessage.readMore)
                    }
                    .hButtonTakeFullWidth(true)

                }
                .padding([.horizontal, .bottom], .padding16)
            }
            .transition(.opacity)
            .frame(width: 300)
        } else {
            ProgressView()
                .foregroundColor(hTextColor.Opaque.primary)
                .frame(width: 300, height: 200)
                .transition(.opacity)
        }
    }
}

@MainActor
class LinkViewModel: ObservableObject {
    @Published var webMetaDataProviderData: WebMetaDataProviderData?
    @Published var error: String?
    let url: URL

    init(url: URL) {
        self.url = url
        getData()

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
