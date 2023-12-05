import Foundation
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct FileView: View {
    let file: FileWrapper
    let onTap: () -> Void

    @ViewBuilder
    var body: some View {
        VStack {
            if file.mimeType.isImage {
                imagePreview
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 4) {
                        Image(uiImage: hCoreUIAssets.pdf.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(hTextColor.secondary)
                            .padding(.horizontal, geometry.size.width / 3)
                            .padding(.top, geometry.size.height / 5)
                        hText(file.name, style: .standardExtraExtraSmall)
                            .foregroundColor(hTextColor.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .background(hFillColor.opaqueOne)
            }
        }
        .onTapGesture {
            onTap()
        }
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let localFile = file.localFile {
            Image(uiImage: UIImage(data: localFile.data) ?? hCoreUIAssets.hedvigBigLogo.image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        } else if let fetchedFile = file.fetchedFile {
            KFImage(fetchedFile.url)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
