import Foundation
import Kingfisher
import SwiftUI
import hCore
import hCoreUI


struct FilesGridView: View {
    let files: [File]
    let options: ClaimFilesViewModel.ClaimFilesViewOptions
    let onDelete: ((_ file: File) -> Void)?
    
    public init(files: [File], options: ClaimFilesViewModel.ClaimFilesViewOptions, onDelete: ((_ file: File) -> Void)? = nil) {
        self.files = files
        self.options = options
        self.onDelete = onDelete
    }
    @PresentableStore private var store: ClaimsStore
    private let adaptiveColumn = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]
    
    var body: some View {
        LazyVGrid(columns: adaptiveColumn, spacing: 8) {
            ForEach(files, id: \.self) { file in
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    FileView(file: file) {
                        store.send(.navigation(action: .openFile(file: file)))
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(12)
                    if options.contains(.delete) {
                        Button(action: {
                            onDelete?(file)
                        }, label: {
                            Image(uiImage: HCoreUIAsset.closeSmall.image)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(hTextColor.secondary)
                        })
                        .frame(width: 24, height: 24)
                        .background(hBackgroundColor.primary)
                        .clipShape(Circle())
                        .hShadow()
                        .offset(.init(width: 4, height: -4))
                        
                    }
                }
            }
        }
    }
}

#Preview{
    let files: [File] = [
        .init(
            id: "imageId1",
            size: 22332,
            mimeType: .PNG,
            name: "test-image",
            source: .url(url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!)
        ),
        
        .init(
            id: "imageId2",
            size: 53443,
            mimeType: MimeType.PNG,
            name: "test-image2",
            source: .url(url: URL(string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png")!)
        ),
        .init(
            id: "imageId3",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image3",
            source: .url(url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!)
        ),
        .init(
            id: "imageId4",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image4",
            source: .url(url: URL(string: "https://flif.info/example-images/fish.png")!)
        ),
        .init(
            id: "imageId5",
            size: 52176,
            mimeType: MimeType.PDF,
            name: "test-pdf long name it is possible to have it is long name .pdf",
            source: .url(url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!)
        ),
    ]
    return FilesGridView(files: files, options: [.add, .delete]) { file in
//        print("optopn")
    }
}

struct FileView: View {
    let file: File
    let onTap: () -> Void

    @ViewBuilder
    var body: some View {
        hText("")
        VStack {
            if file.mimeType.isImage {
                switch file.source {
                case .data(let data):
                    Image(uiImage: UIImage(data: data) ?? hCoreUIAssets.hedvigBigLogo.image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                case .url(let url):
                    KFImage(url)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit
                        )
                }
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
}
