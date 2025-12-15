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
                                title: fileUploadVm.hasFiles ? "Send files" : L10n.ClaimStatusDetail.addFiles
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

                model?.fileUploadVm.fileGridViewModel.files
                    .append(
                        .init(
                            id: "idd6",
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

                model?.fileUploadVm.fileGridViewModel.files
                    .append(
                        .init(
                            id: "idd7",
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
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var mainView: some View {
        if showGrid {
            FilesGridView(vm: viewModel)
        } else {
            CardStack(viewModel.files) { file in
                FileView(file: file) {}
                    .frame(width: 100, height: 116)
                    .background {
                        hBackgroundColor.primary
                    }
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                    .cornerRadius(.padding12)
                    .contentShape(Rectangle())
            }
        }
    }
}

public struct CardStack<Data, Content>: View
where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    @State private var currentIndex: Double = 0.0
    @State private var previousIndex: Double = 0.0
    @State private var swippingLeft = false
    private let data: Data
    @ViewBuilder private let content: (Data.Element) -> Content
    @Binding var finalCurrentIndex: Int

    /// Creates a stack with the given content
    /// - Parameters:
    ///   - data: The identifiable data for computing the list.
    ///   - currentIndex: The index of the topmost card in the stack
    ///   - content: A view builder that creates the view for a single card
    public init(
        _ data: Data,
        currentIndex: Binding<Int> = .constant(0),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = content
        _finalCurrentIndex = currentIndex
    }

    public var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.element.id) { (index, element) in
                content(element)
                    .zIndex(zIndex(for: index))
                    .offset(x: xOffset(for: index), y: 0)
                    .scaleEffect(scale(for: index), anchor: .center)
                    .rotationEffect(.degrees(rotationDegrees(for: index)))
            }
        }
        .highPriorityGesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                swippingLeft = value.translation.width < 0
                withAnimation(.interactiveSpring()) {
                    let x = (value.translation.width / 300) - previousIndex
                    self.currentIndex = -x
                }
            }
            .onEnded { value in
                self.snapToNearestAbsoluteIndex(value.predictedEndTranslation)
                self.previousIndex = self.currentIndex
            }
    }

    private func snapToNearestAbsoluteIndex(_ predictedEndTranslation: CGSize) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 40)) {
            let translation = predictedEndTranslation.width
            if abs(translation) > 200 {
                if translation > 0 {
                    self.goTo(round(self.previousIndex) - 1)
                } else {
                    self.goTo(round(self.previousIndex) + 1)
                }
            } else {
                self.currentIndex = round(currentIndex)
            }
        }
    }

    private func goTo(_ index: Double) {
        let maxIndex = Double(data.count - 1)
        if index < 0 {
            self.currentIndex = 0
        } else if index > maxIndex {
            self.currentIndex = maxIndex
        } else {
            self.currentIndex = index
        }
        self.finalCurrentIndex = Int(index)
    }

    private func zIndex(for index: Int) -> Double {
        var value: Double = {
            if swippingLeft {
                if (Double(index) + 0.5) < currentIndex {
                    return -Double(data.count - index)
                } else {
                    return Double(data.count - index)
                }
            } else {
                if (Double(index) + 0.5) < currentIndex {
                    return -Double(data.count - index)
                } else {
                    return Double(data.count - index)
                }
            }
        }()

        print("INDEX \(value) for \(index) \(currentIndex) \(swippingLeft)")

        return value
    }

    private func xOffset(for index: Int) -> CGFloat {
        if swippingLeft {
            let topCardProgress = currentPosition(for: index)
            let padding = 40.0
            let x = ((CGFloat(index) - currentIndex) * padding)
            if topCardProgress > 0 && topCardProgress < 0.99 && index < (data.count - 1) {
                let value = x * swingOutMultiplier(topCardProgress)
                return value
            }
            return x
        } else {
            let topCardProgress = currentPosition(for: index)
            let padding = 40.0
            let x = ((CGFloat(index) - currentIndex) * padding)
            if topCardProgress > -1 && topCardProgress < 0 && index < (data.count) {
                let value = x * swingOutMultiplier(topCardProgress)
                return -value
            }
            return x
        }
    }

    private func scale(for index: Int) -> CGFloat {
        1.0 - (0.1 * abs(currentPosition(for: index)))
    }

    private func rotationDegrees(for index: Int) -> Double {
        -currentPosition(for: index) * 2
    }

    private func currentPosition(for index: Int) -> Double {
        currentIndex - Double(index)
    }

    private func swingOutMultiplier(_ progress: Double) -> Double {
        sin(Double.pi * progress) * 5
    }
}
