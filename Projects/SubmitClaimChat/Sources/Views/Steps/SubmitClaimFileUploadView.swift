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
                        .overlay {
                            if fileUploadVm.isLoading {
                                GeometryReader { geo in
                                    Rectangle()
                                        .fill(hGrayscaleTranslucent.greyScaleTranslucent800)
                                        .opacity(fileUploadVm.progress)
                                        .frame(width: fileUploadVm.progress * geo.size.width)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                            }
                        }
                        if fileUploadVm.hasFiles {
                            hButton(
                                .large,
                                .secondary,
                                content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
                                { [weak viewModel] in
                                    viewModel?.showFileSourcePicker = true
                                }
                            )
                            .transition(.offset(x: 0, y: 100).combined(with: .opacity))
                        }
                    }
                    .hButtonIsLoading(false)
                }
            }
        }
        .disabled(fileUploadVm.isLoading)
        .sectionContainerStyle(.transparent)
        .animation(.default, value: fileUploadVm.hasFiles)
        .animation(.default, value: fileUploadVm.isLoading)
        .animation(.default, value: fileUploadVm.progress)
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
    @State var showGrid = false
    var body: some View {
        VStack(alignment: .trailing) {
            mainView
            if viewModel.hasMoreFiles {
                hButton(
                    .small,
                    .secondaryAlt,
                    content: .init(title: showGrid ? "Collapse" : "Expand"),
                    {
                        withAnimation {
                            showGrid.toggle()
                        }
                    }
                )
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var mainView: some View {
        if showGrid || !viewModel.hasMoreFiles {
            FilesGridView(vm: viewModel)
        } else {
            StackedFilesView(vm: viewModel)
        }
    }
}

struct StackedFilesView: View {
    @ObservedObject var vm: FileGridViewModel
    var body: some View {
        ZStack(alignment: .center) {
            ForEach(Array(vm.getFilesToShow().enumerated()), id: \.element.id) { (index, element) in
                FileView(file: element) {}
                    .frame(width: 100, height: 116)
                    .background {
                        hBackgroundColor.primary
                    }
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))

                    .cornerRadius(.padding12)
                    .offset(x: CGFloat(index * 10), y: CGFloat(index * -10))

                    .rotationEffect(.degrees(Double(index) * 7.34), anchor: .bottomTrailing)

                    .contentShape(Rectangle())
            }
        }
        .padding(.top, vm.additionalHeight)
        .padding(.trailing, vm.additionalWidth)
        .fixedSize(horizontal: true, vertical: true)
        .rotationEffect(vm.angle, anchor: .top)
    }
}

extension FileGridViewModel {
    fileprivate func getFilesToShow() -> [File] {
        if files.count <= 3 {
            return files
        }
        return Array(files.prefix(3))
    }

    fileprivate var angle: Angle {
        switch files.count {
        case 3...: return .init(degrees: -7.34)
        default: return .init(degrees: 0)
        }
    }

    fileprivate var additionalHeight: CGFloat {
        switch files.count {
        case 3...: return 2 * 10
        case 2: return 10
        default: return 0
        }
    }

    fileprivate var additionalWidth: CGFloat {
        switch files.count {
        case 3...: return 50
        case 2: return 10
        default: return 0
        }
    }

    fileprivate var hasMoreFiles: Bool {
        files.count > 1
    }
}
