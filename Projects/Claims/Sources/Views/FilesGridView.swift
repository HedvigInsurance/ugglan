import Foundation
import Home
import Kingfisher
import PresentableStore
import SafariServices
import SwiftUI
import UniformTypeIdentifiers
import hCore
import hCoreUI

struct FilesGridView: View {
    @ObservedObject var vm: FileGridViewModel

    private let adaptiveColumn = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        LazyVGrid(columns: adaptiveColumn, spacing: 8) {
            ForEach(vm.files, id: \.id) { file in
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    FileView(file: file) {
                        vm.show(file: file)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .opacity(vm.options.contains(.loading) ? 0.5 : 1)
                    if vm.options.contains(.delete) {
                        Button(
                            action: {
                                vm.delete(file)
                            },
                            label: {
                                Circle().fill(Color.clear)
                                    .frame(width: 30, height: 30)
                                    .hShadow()
                                    .overlay(
                                        Circle().fill(hBackgroundColor.primary)
                                            .frame(width: 24, height: 24)
                                            .hShadow()
                                            .overlay(
                                                Image(uiImage: HCoreUIAsset.closeSmall.image)
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .foregroundColor(hTextColor.Opaque.secondary)
                                            )
                                    )
                                    .offset(.init(width: 8, height: -8))
                            }
                        )
                        .zIndex(.infinity)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .detent(
            item: $vm.fileModel,
            style: [.large]
        ) { model in
            DocumentPreview(vm: .init(type: model.type.asDocumentPreviewModelType))
        }
    }
}

class FileGridViewModel: ObservableObject {
    @Published var files: [File]
    @Published private(set) var options: ClaimFilesViewModel.ClaimFilesViewOptions
    @Published var fileModel: HomeNavigationViewModel.FileUrlModel?
    var onDelete: ((_ file: File) -> Void)?

    init(
        files: [File],
        options: ClaimFilesViewModel.ClaimFilesViewOptions,
        onDelete: ((_ file: File) -> Void)? = nil
    ) {
        self.files = files
        self.options = options
        self.onDelete = onDelete
    }

    func delete(_ file: File) {
        let alert = UIAlertController(
            title: L10n.General.areYouSure,
            message: L10n.claimsFileUploadRemoveSubtitle,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: L10n.claimsFileUploadRemoveCancel,
                style: .default,
                handler: { _ in

                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.claimsFileUploadRemoveConfirm,
                style: .default,
                handler: { [weak self] _ in
                    self?.onDelete?(file)
                }
            )
        )

        UIApplication.shared.getTopViewController()?.present(alert, animated: true, completion: nil)
    }

    func update(options: ClaimFilesViewModel.ClaimFilesViewOptions) {
        withAnimation {
            self.options = options
        }
    }

    @MainActor
    func show(file: File) {
        switch file.source {
        case let .localFile(results):
            results?.itemProvider
                .loadDataRepresentation(
                    forTypeIdentifier: UTType.item.identifier,
                    completionHandler: { [weak self] data, error in
                        if let data {
                            Task { @MainActor in
                                self?.fileModel = .init(type: .data(data: data, mimeType: file.mimeType))
                            }
                        }
                    }
                )
        case .url(let url):
            fileModel = .init(type: .url(url: url))
        case .data(let data):
            fileModel = .init(type: .data(data: data, mimeType: file.mimeType))
        }
    }
}

#Preview {
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
            source: .url(
                url: URL(string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png")!
            )
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
    return FilesGridView(vm: .init(files: files, options: [.delete]))
}
