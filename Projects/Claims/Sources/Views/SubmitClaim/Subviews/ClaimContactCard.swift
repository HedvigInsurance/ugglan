import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI
import Kingfisher

struct ClaimContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var title: String?
    var imageUrl: String
    var label: String
    var url: String?
    var buttonText: String
    
    init(
        imageUrl: String,
        label: String,
        url: String,
        title: String? = nil,
        buttonText: String
    ) {
        self.imageUrl = imageUrl
        self.label = label
        self.url = url
        self.title = title
        self.buttonText = buttonText
    }
    
    var body: some View {
        if let title {
            hSection {
                sectionContent
            }
            .withHeader({
                HStack {
                    hText(title)
                    Spacer()
                    Image(uiImage: hCoreUIAssets.infoSmall.image)
                        .foregroundColor(hTextColorNew.secondary)
                        .fixedSize()
                        .onTapGesture {
                            store.send(
                                .navigationAction(
                                    action: .openInfoScreen(title: L10n.submitClaimPartnerTitle, description: "")
                                )
                            )
                        }
                }
            })
            .sectionContainerStyle(.black)
        } else {
            hSection {
                sectionContent
            }
            .sectionContainerStyle(.black)
        }
    }
    
    private var sectionContent: some View {
        VStack(spacing: 8) {
            if let imageUrl = URL(string: imageUrl) {
                ImageView(imageUrl: imageUrl)
                //                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .foregroundColor(hTextColorNew.negative)
                    .padding(.vertical, 16)
            }
            
            hText(label)
                .multilineTextAlignment(.center)
                .foregroundColor(hTextColorNew.tertiary)
                .padding(.bottom, 8)
                .padding(.horizontal, 8)
            hButton.MediumButtonSecondaryAlt {
                if let url = URL(string: url) {
                    UIApplication.shared.open(url)
                }
            } content: {
                hText(buttonText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
    }
}

struct ImageView: UIViewRepresentable {
    var imageUrl: URL
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeUIView(context: Context) -> some UIView {
        let imageView = UIImageView()
        imageView.kf.setImage(with: imageUrl, options: [.processor(SVGImageProcessor())])
        return imageView
    }
}

struct ClaimContactCard_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return VStack {
            ClaimContactCard(imageUrl: "", label: "LABEL", url: "BUTTON TEXT", buttonText: "")
            ClaimContactCard(
                imageUrl: "",
                label: "VERY LONG LABEL TEXT VERY LONG LABEL TEXT VERY LONG LABEL TEXT VERY LONG LABEL TEXT",
                url: "BUTTON TEXT",
                buttonText: ""
            )
            ClaimContactCard(
                imageUrl: "",
                label: "LABEL",
                url: "VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT",
                buttonText: ""
            )
            
        }
        
    }
}
