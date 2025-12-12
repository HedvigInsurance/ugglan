import Foundation
import Kingfisher
import SafariServices
import SwiftUI
import hCore
import hCoreUI

public struct FilesGridView: View {
    @ObservedObject var vm: FileGridViewModel
    @Environment(\.hFileGridAlignment) var alignment

    public init(
        vm: FileGridViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: .padding4) {
            ForEach(Array(stride(from: 0, to: vm.files.count, by: 3)), id: \.self) { rowIndex in
                HStack(spacing: .padding4) {
                    if alignment == .trailing {
                        Spacer()
                    }
                    ForEach(Array(stride(from: rowIndex, to: min(rowIndex + 3, vm.files.count), by: 1)), id: \.self) {
                        index in
                        let file = vm.files[index]
                        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                            FileView(file: file) {
                                vm.show(file: file)
                            }
                            .frame(width: 100, height: 100)
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(.padding12)
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
                                                        hCoreUIAssets.closeSmall.view
                                                            .resizable()
                                                            .frame(width: 16, height: 16)
                                                            .foregroundColor(hTextColor.Opaque.secondary)
                                                    )
                                            )
                                            .offset(.init(width: 8, height: -8))
                                            .accessibilityLabel(L10n.General.remove)
                                    }
                                )
                                .zIndex(.infinity)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    if alignment == .leading {
                        Spacer()
                    }
                }
            }
        }
        .detent(
            item: $vm.fileModel,
            transitionType: .detent(style: [.large])
        ) { model in
            DocumentPreview(vm: .init(type: model.type.asDocumentPreviewModelType))
        }
    }
}

@MainActor
public class FileGridViewModel: ObservableObject {
    @Published public var files: [File] {
        didSet {
            setColumns()
        }
    }
    @Published public var options: ClaimFilesViewModel.ClaimFilesViewOptions
    @Published var fileModel: FileUrlModel?

    @Published private(set) var columns: [GridItem] = []
    public var onDelete: ((_ file: File) -> Void)?

    public init(
        files: [File],
        options: ClaimFilesViewModel.ClaimFilesViewOptions,
        onDelete: ((_ file: File) -> Void)? = nil
    ) {
        self.files = files
        self.options = options
        self.onDelete = onDelete
        self.setColumns()
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

    private func setColumns() {
        if files.count >= 3 {
            columns = [
                GridItem(.flexible(), spacing: .padding8),
                GridItem(.flexible(), spacing: .padding8),
                GridItem(.flexible(), spacing: .padding8),
            ]
        } else if files.count == 2 {
            columns = [
                GridItem(.flexible(), spacing: .padding8),
                GridItem(.flexible(), spacing: .padding8),
            ]
        } else {
            columns = [
                GridItem(.flexible(), spacing: .padding8)
            ]
        }
    }

    public func update(options: ClaimFilesViewModel.ClaimFilesViewOptions) {
        withAnimation {
            self.options = options
        }
    }

    @MainActor
    func show(file: File) {
        switch file.source {
        case let .localFile(results):
            Task { @MainActor [weak self] in
                if let data = try? await results?.itemProvider.getData().data {
                    self?.fileModel = .init(type: .data(data: data, name: file.name, mimeType: file.mimeType))
                }
            }
        case let .url(url, mimeType):
            fileModel = .init(type: .url(url: url, name: file.name, mimeType: mimeType))
        case let .data(data):
            fileModel = .init(type: .data(data: data, name: file.name, mimeType: file.mimeType))
        }
    }
}

@MainActor
private struct FileGridAlignment: @preconcurrency EnvironmentKey {
    static let defaultValue: HorizontalAlignment = .trailing
}

extension EnvironmentValues {
    public var hFileGridAlignment: HorizontalAlignment {
        get { self[FileGridAlignment.self] }
        set { self[FileGridAlignment.self] = newValue }
    }
}

extension View {
    public func hFileGridAlignment(alignment: HorizontalAlignment) -> some View {
        environment(\.hFileGridAlignment, alignment)
    }
}

#Preview {
    let files: [File] = [
        .init(
            id: "imageId1",
            size: 22332,
            mimeType: .PNG,
            name: "test-image",
            source: .url(
                url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!,
                mimeType: .PNG
            )
        ),

        .init(
            id: "imageId2",
            size: 53443,
            mimeType: MimeType.PNG,
            name: "test-image2",
            source: .url(
                url: URL(string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png")!,
                mimeType: .PNG
            )
        ),
        .init(
            id: "imageId3",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image3",
            source: .url(
                url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!,
                mimeType: .PNG
            )
        ),
        .init(
            id: "imageId4",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image4",
            source: .url(url: URL(string: "https://flif.info/example-images/fish.png")!, mimeType: .PNG)
        ),
        .init(
            id: "imageId5",
            size: 52176,
            mimeType: MimeType.PDF,
            name: "test-pdf long name it is possible to have it is long name .pdf",
            source: .url(
                url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
                mimeType: .PDF
            )
        ),
    ]
    return ScrollView {
        VStack(alignment: .leading, spacing: .padding32) {
            FilesGridView(vm: .init(files: [files[0]], options: [.delete]))
            FilesGridView(vm: .init(files: [files[0], files[1]], options: [.delete]))
            FilesGridView(vm: .init(files: [files[0], files[1], files[2]], options: [.delete]))
            FilesGridView(vm: .init(files: [files[0], files[1], files[2], files[3]], options: [.delete]))
            FilesGridView(vm: .init(files: [files[0], files[1], files[2], files[3], files[4]], options: [.delete]))
        }
    }
}
