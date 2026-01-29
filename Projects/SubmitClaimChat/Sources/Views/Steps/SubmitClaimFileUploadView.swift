import Claims
import Combine
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimFileUploadView: View {
    @ObservedObject var viewModel: SubmitClaimFileUploadStep
    @ObservedObject var fileUploadVm: FilesUploadViewModel

    init(
        viewModel: SubmitClaimFileUploadStep
    ) {
        fileUploadVm = viewModel.fileUploadVm
        self.viewModel = viewModel
    }

    var body: some View {
        showFilesView
            .showFileSourcePicker($viewModel.showFileSourcePicker) { files in
                fileUploadVm.addFiles(with: files)
            }
            .onChange(of: fileUploadVm.hasFiles) { hasFiles in
                viewModel.setDisableSkip(to: hasFiles)
            }
    }

    private var showFilesView: some View {
        Group {
            hSection {
                VStack {
                    FilesGridView(vm: fileUploadVm.fileGridViewModel)
                        .hFileGridAlignment(alignment: .leading)
                    VStack(spacing: .padding8) {
                        if fileUploadVm.hasFiles {
                            addMoreFilesButton
                        }
                        sendOrAddFilesButton
                    }
                    .hButtonIsLoading(false)
                    .animation(.default, value: fileUploadVm.hasFiles)
                }
            }
        }
        .disabled(fileUploadVm.isLoading)
        .sectionContainerStyle(.transparent)
        .animation(.default, value: fileUploadVm.isLoading)
        .animation(.default, value: fileUploadVm.progress)
    }

    @ViewBuilder
    private var addMoreFilesButton: some View {
        hButton(
            .large,
            .secondary,
            content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
            { [weak viewModel] in
                viewModel?.showFileSourcePicker = true
            }
        )
        .transition(.opacity)
    }

    @ViewBuilder
    private var sendOrAddFilesButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(
                title: fileUploadVm.hasFiles
                    ? L10n.claimChatFileUploadSendButton : L10n.ClaimStatusDetail.addFiles
            )
        ) {
            if fileUploadVm.hasFiles {
                viewModel.submitResponse()
            } else {
                viewModel.showFileSourcePicker = true
            }
        }
        .animation(nil, value: fileUploadVm.hasFiles)
        .overlay {
            if fileUploadVm.isLoading {
                GeometryReader { geo in
                    Rectangle()
                        .fill(hGrayscaleTranslucent.greyScaleTranslucent800)
                        .opacity(fileUploadVm.progress)
                        .frame(width: fileUploadVm.progress * geo.size.width)
                }
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.ClaimStatusDetail.addFiles)
                .accessibilityValue(String(format: "%.0f%%", fileUploadVm.progress * 100))
                .accessibilityAddTraits(.updatesFrequently)
            }
        }
    }
}

public struct FileUploadModel: Sendable {
    var uploadUri: String? = nil
    @State var uploads: [FileModel] = []
}

public struct FileModel: Codable, Equatable, Hashable, Sendable {
    let fileId: String
    let signedUrl: String
    let mimeType: String
    let name: String

    public init(fileId: String, signedUrl: String, mimeType: String, name: String) {
        self.fileId = fileId
        self.signedUrl = signedUrl
        self.mimeType = mimeType
        self.name = name
    }
}

#Preview {
    let model = ClaimIntentClientDemo().demoFileUploadModel

    return VStack {
        Spacer()
        SubmitClaimFileUploadView(viewModel: model)
            .task { [weak model] in
                try? await Task.sleep(seconds: 1)
                model?.fileUploadVm.fileGridViewModel.files
                    .append(
                        .init(
                            id: "idd1",
                            size: 0,
                            mimeType: .PNG,
                            name: "name",
                            source: .url(
                                url: URL(
                                    string:
                                        "https://fujiframe.com/assets/images/_3000x2000_fit_center-center_85_none/970/XH2S1833-Fujifilm-Fujinon-XF70-300mmF4-5.6-R-LM-OIS-WR.webp"
                                )!,
                                mimeType: .PNG
                            )
                        )
                    )

                model?.fileUploadVm.fileGridViewModel.files
                    .append(
                        .init(
                            id: "idd3",
                            size: 0,
                            mimeType: .PNG,
                            name: "name 3",
                            source: .url(
                                url: URL(
                                    string:
                                        "https://fujiframe.com/assets/images/_3000x2000_fit_center-center_85_none/10085/xhs2-fuji-70-300-Amazilia-Hummingbird.webp"
                                )!,
                                mimeType: .PNG
                            )
                        )
                    )

                model?.fileUploadVm.fileGridViewModel.files
                    .append(
                        .init(
                            id: "idd2",
                            size: 0,
                            mimeType: .PNG,
                            name: "name 2",
                            source: .url(
                                url: URL(
                                    string:
                                        "https://fujiframe.com/assets/images/_3000x2000_fit_center-center_85_none/1168/fuji-70-300-review-00011.webp"
                                )!,
                                mimeType: .PNG
                            )
                        )
                    )
                model?.fileUploadVm.fileGridViewModel.files
                    .append(
                        .init(
                            id: "idd5",
                            size: 0,
                            mimeType: .PNG,
                            name: "name 3",
                            source: .url(
                                url: URL(
                                    string:
                                        "https://fujiframe.com/assets/images/_3000x2000_fit_center-center_85_none/964/XH2S1419-Fujifilm-Fujinon-XF70-300mmF4-5.6-R-LM-OIS-WR.webp"
                                )!,
                                mimeType: .PNG
                            )
                        )
                    )
            }
        SubmitClaimFileUploadResultView(viewModel: model.fileUploadVm.fileGridViewModel)
    }
}

struct SubmitClaimFileUploadResultView: View {
    @ObservedObject var viewModel: FileGridViewModel
    @State private var fileModel: FileUrlModel?
    var body: some View {
        VStack(alignment: .trailing) {
            CardStack(viewModel.files) { file in
                FileView(file: file) {
                    switch file.source {
                    case let .localFile(results):
                        Task { @MainActor in
                            if let data = try? await results?.itemProvider.getData().data {
                                self.fileModel = .init(
                                    type: .data(data: data, name: file.name, mimeType: file.mimeType)
                                )
                            }
                        }
                    case let .url(url, mimeType):
                        fileModel = .init(type: .url(url: url, name: file.name, mimeType: mimeType))
                    case let .data(data):
                        fileModel = .init(type: .data(data: data, name: file.name, mimeType: file.mimeType))
                    }
                }
                .frame(width: 150, height: 174)
                .background {
                    hBackgroundColor.primary
                }
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .cornerRadius(.padding12)
                .contentShape(Rectangle())
            }
        }
        .sectionContainerStyle(.transparent)
        .detent(
            item: $fileModel,
            transitionType: .detent(style: [.large])
        ) { model in
            DocumentPreview(vm: .init(type: model.type.asDocumentPreviewModelType))
        }
    }
}
